import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:weave_it/core/di/get_it.dart';
import 'package:weave_it/core/theme/app_theme.dart';
import 'package:weave_it/features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is properly initialized

  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weave It',
      theme: AppTheme.getTheme(),
      home: LoginScreen(),
      
    );
  }
}
