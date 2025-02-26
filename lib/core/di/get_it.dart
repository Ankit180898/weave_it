import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  _initAuth();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Get environment variables
  final supaUri = dotenv.env['SUPABASE_URL'];
  final supaAnon = dotenv.env['SUPABASE_ANONKEY'];

  // Check if environment variables are properly loaded
  if (supaUri == null || supaAnon == null) {
    throw Exception('Missing Supabase credentials in the .env file');
  }

  // Initialize Supabase
  final supabase = await Supabase.initialize(url: supaUri, anonKey: supaAnon);
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory(() => InternetConnection());

  // core
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(serviceLocator()),
  );
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    // Controller
    ..registerLazySingleton(() => AuthController(serviceLocator()));
}
