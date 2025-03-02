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
  static const String usersTable = 'app_users'; // Renamed table to avoid conflict

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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw ServerExceptions('Failed to retrieve Google ID Token.');
      }

      print('Signing in to Supabase with Google ID Token...');
      final AuthResponse response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final Session? session = response.session;
      if (session == null) {
        throw ServerExceptions('Google Sign-In failed: No session established.');
      }

      final User user = session.user;
      if (user.email == null) {
        throw ServerExceptions('User email is null.');
      }

      final Map<String, dynamic> userData = {
        'id': user.id,
        'email': user.email,
        'display_name': user.userMetadata?['name'] ?? googleUser.displayName ?? user.email,
        'avatar_url': user.userMetadata?['picture'] ?? googleUser.photoUrl ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Upserting user data into $usersTable: $userData');


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
          await supabaseClient.from(usersTable).select().eq('id', userId).maybeSingle();

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
      print('User successfully logged out.');
    } on AuthException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<void> deleteUser({required String userId}) async {
    try {
      print('Deleting user $userId from Supabase Auth...');
      await supabaseClient.auth.admin.deleteUser(userId);

      print('Deleting user data from $usersTable...');
      await supabaseClient.from(usersTable).delete().eq('id', userId);

      print('User deletion successful.');
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }
}
