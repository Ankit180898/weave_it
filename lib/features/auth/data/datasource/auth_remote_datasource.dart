import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weave_it/core/failure/server_exception.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';

abstract class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signInWithGoogle();
  Future<UserModel?> getCurrentUserData();
  Future<void> logout();
  Future<void> deleteUser({required String userId});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '581088833405-ub1dcavjot4mril331fkpgud9n2mvhi5.apps.googleusercontent.com',
  );

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign out previous Google session (if any)
      await _googleSignIn.signOut();

      // Start Google Sign-In Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerExceptions('Google Sign-In was canceled by the user.');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw ServerExceptions(
          'No ID Token found. Check Google Cloud Console configuration.',
        );
      }

      // Sign in with Supabase using Google OAuth
      final AuthResponse res = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.session == null) {
        throw ServerExceptions('Failed to authenticate with Supabase.');
      }

      final User user = res.user!;
      final String userId = user.id;

      // Wait for Supabase trigger to insert the user
      await Future.delayed(const Duration(milliseconds: 800));

      // Retry logic: Check if user exists in 'users' table
      Map<String, dynamic>? userData;
      int retries = 5;
      while (retries > 0) {
        userData = await supabaseClient
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userData != null) break;
        await Future.delayed(const Duration(milliseconds: 300));
        retries--;
      }

      // If userData is still null, throw an error
      if (userData == null) {
        throw ServerExceptions(
            'User data was not inserted into the users table.');
      }

      return UserModel(
        id: userId,
        name: userData['display_name'] ?? googleUser.displayName ?? '',
        email: userData['email'] ?? user.email ?? '',
        avatar_url: userData['avatar_url'] ?? googleUser.photoUrl ?? '',
      );
    } catch (e) {
      debugPrint("Google Sign-In Error: ${e.toString()}");
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final session = currentUserSession;
      if (session == null) return null;

      final userId = session.user.id;
      final userData = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return userData != null ? UserModel.fromJson(userData) : null;
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<void> deleteUser({required String userId}) async {
    try {
      // Delete user from Supabase Auth
      await supabaseClient.auth.admin.deleteUser(userId);

      // Delete user from 'users' table
      await supabaseClient.from('users').delete().eq('id', userId);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }
}
