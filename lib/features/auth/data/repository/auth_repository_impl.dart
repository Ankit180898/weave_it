import 'package:fpdart/fpdart.dart';
import 'package:weave_it/core/constants/constants.dart';
import 'package:weave_it/core/failure/failure.dart';
import 'package:weave_it/core/failure/server_exception.dart';
import 'package:weave_it/core/network/connection_checker.dart';
import 'package:weave_it/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';
import 'package:weave_it/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, UserModel>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure('User not logged in!'));
        }

        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            name: '',
          ),
        );
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure(   'User not logged in!'));
      }

      return right(user);
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, UserModel>> _getUser(
    Future<UserModel> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure( 'No Internet'));
      }
      final user = await fn();

      return right(user);
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> logout() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await remoteDataSource.logout();
      return right(UserModel(id: '', email: '', name: ''));
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser({required String userId}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      await remoteDataSource.deleteUser(userId: userId);
      return right(null);
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> editUser({
    required String userId,
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final updatedUser = await remoteDataSource.editProfile(
        userId: userId,
        name: name,
        email: email,
        password: password,
      );

      return right(updatedUser);
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }
}
