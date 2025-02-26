import 'package:get/get.dart';
import 'package:weave_it/features/auth/domain/model/user_model.dart';
import 'package:weave_it/features/auth/domain/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  AuthController(this._authRepository);

  Future<void> signUp(String name, String email, String password) async {
    isLoading.value = true;
    final result = await _authRepository.signUpWithEmailPassword(
        name: name, email: email, password: password);

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (userData) => user.value = userData,
    );

    isLoading.value = false;
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    final result = await _authRepository.loginWithEmailPassword(
        email: email, password: password);

    result.fold(
      (failure) => errorMessage.value = failure.message,
      (userData) => user.value = userData,
    );

    isLoading.value = false;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
  }
}
