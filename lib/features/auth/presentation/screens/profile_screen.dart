import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weave_it/features/auth/presentation/controllers/auth_controller.dart';
import 'package:weave_it/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: ()  {
              // await authController.logout();
              Get.offAll(() => LoginScreen()); // Navigate back to login screen
            },
          ),
        ],
      ),
      body: Obx(() {
        if (authController.user.value == null) {
          return Center(child: Text('Not logged in'));
        }
        final user = authController.user.value!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
              Text('Avatar URL: ${user.avatar_url}'),
            ],
          ),
        );
      }),
    );
  }
}