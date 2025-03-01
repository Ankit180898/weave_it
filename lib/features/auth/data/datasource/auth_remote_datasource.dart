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
    scopes: ['email', 'profile', 'openid'],
  );
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In flow...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerExceptions('Google Sign-In was canceled by the user.');
      }
      print('Google Sign-In successful. User: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      if (idToken == null) {
        throw ServerExceptions('Failed to retrieve Google ID Token.');
      }
      print(
        'Google ID Token retrieved. Access Token: $accessToken',
      ); // Log access token for debugging

      print('Signing in to Supabase with Google ID Token...');
      final AuthResponse response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken, // Ensure access_token is included if needed
      );

      final Session? session = response.session;
      if (session == null) {
        throw ServerExceptions(
          'Google Sign-In failed: No session established.',
        );
      }
      print('Supabase session established. User ID: ${session.user.id}');
      print('User metadata: ${session.user.userMetadata}');

      final User user = session.user;
      if (user.email == null) {
        throw ServerExceptions('User ID or email is null.');
      }

      final Map<String, dynamic> userData = {
        'id': user.id,
        'email': user.email,
        'display_name':
            user.userMetadata?['name'] ?? googleUser.displayName ?? user.email,
        'avatar_url':
            user.userMetadata?['picture'] ?? googleUser.photoUrl ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('User data to upsert: $userData');
      final upsertResponse = await supabaseClient
          .from('users')
          .upsert(userData, onConflict: 'id');
      print('Upsert response: $upsertResponse');

      return UserModel(
        id: user.id,
        name: userData['display_name'],
        email: userData['email'],
        avatar_url: userData['avatar_url'],
      );
    } catch (e) {
      print('Error during Google Sign-In: $e');
      throw ServerExceptions('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      final session = currentUserSession;
      if (session == null) return null;

      final userId = session.user.id;
      final userData =
          await supabaseClient
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
