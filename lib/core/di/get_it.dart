import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weave_it/core/network/connection_checker.dart';
import 'package:weave_it/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:weave_it/features/auth/data/repository/auth_repository_impl.dart';
import 'package:weave_it/features/auth/domain/repository/auth_repository.dart';
import 'package:weave_it/features/auth/presentation/controllers/auth_controller.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Get environment variables
  final supaUri = dotenv.env['SUPABASE_URL'];
  final supaAnon = dotenv.env['SUPABASE_ANONKEY'];

  if (supaUri == null || supaAnon == null) {
    throw Exception('Missing Supabase credentials in the .env file');
  }

  // Initialize Supabase
  await Supabase.initialize(url: supaUri, anonKey: supaAnon);
  final supabaseClient = Supabase.instance.client;
  serviceLocator.registerLazySingleton(() => supabaseClient);

  // Register InternetConnection
  serviceLocator.registerFactory(() => InternetConnection());

  // Register ConnectionChecker
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );

  // Initialize Auth dependencies
  _initAuth();
}

void _initAuth() {
  // Datasource
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(serviceLocator()),
  );

  // Repository
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
  );

  // Use Get.put() to register AuthController with GetX
  Get.put(AuthController(serviceLocator()));
}
