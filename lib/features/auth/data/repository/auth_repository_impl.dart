import 'package:fpdart/fpdart.dart';
import 'package:weave_it/core/failure/failure.dart';
import 'package:weave_it/core/failure/server_exception.dart';
import 'package:weave_it/core/network/connection_checker.dart';
import 'package:weave_it/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';
import 'package:weave_it/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure('No Internet'));
      }
      final user = await remoteDataSource.signInWithGoogle();
      return right(user);
    } on ServerExceptions catch (e) {
      return left(Failure(e.message));
    }
  }
}
