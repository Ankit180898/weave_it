import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weave_it/core/failure/server_exception.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';

abstract class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> logout();
  Future<void> deleteUser({required String userId});

  Future<UserModel> editProfile({
    required String userId,
    String? name,
    String? email,
    String? password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerExceptions('User is null');
      }
      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'name': name},
      );
      if (response.user == null) {
        throw const ServerExceptions('User is null');
      }
      return UserModel.fromJson(response.user!.toJson());
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
              'id',
              currentUserSession!.user.id,
            );
        return UserModel.fromJson(userData.first);
      }
      return null;
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }
  
  @override
  Future<void> deleteUser({required String userId}) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }
  
  @override
  Future<UserModel> editProfile({required String userId, String? name, String? email, String? password}) {
    // TODO: implement editProfile
    throw UnimplementedError();
  }

}