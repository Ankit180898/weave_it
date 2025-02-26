

import 'package:fpdart/fpdart.dart';
import 'package:weave_it/core/failure/failure.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserModel>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> currentUser();

  Future<Either<Failure, void>> logout();

  // Edit user profile
  Future<Either<Failure, UserModel>> editUser({
    required String userId,
    String? name,
    String? email,
    String? password,
  });

  // Delete user account
  Future<Either<Failure, void>> deleteUser({required String userId});
}
