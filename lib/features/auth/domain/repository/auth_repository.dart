import 'package:fpdart/fpdart.dart';
import 'package:weave_it/core/failure/failure.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserModel>> signInWithGoogle();
}
