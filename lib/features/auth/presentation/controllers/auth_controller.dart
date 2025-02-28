import 'package:get/get.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';
import 'package:weave_it/features/auth/domain/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  AuthController(this._authRepository);

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authRepository.signInWithGoogle();
      result.fold((l) => errorMessage.value = l.message, (r) => user.value = r);
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      isLoading.value = false;
    }
  }
}
