import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weave_it/features/auth/presentation/controllers/auth_controller.dart';
import 'package:weave_it/features/auth/presentation/screens/profile_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (authController.errorMessage.value.isNotEmpty) {
          return Center(child: Text(authController.errorMessage.value));
        }
        return Center(
          child: ElevatedButton(
            onPressed: () async {
              await authController.signInWithGoogle();
              if (authController.user.value != null) {
                Get.offAll(() => ProfileScreen()); // Navigate to home screen
              }
            },
            child: Text('Sign in with Google'),
          ),
        );
      }),
    );
  }
}