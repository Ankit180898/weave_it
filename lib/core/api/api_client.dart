// import 'package:dio/dio.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ApiClient {
//   Dio getDio({bool tokenInterceptor = false}) {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConfig.BASE_URL,
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 10),
//         contentType: 'application/json',
//       ),
//     );

//     // Add Pretty Logger for Debugging
//     dio.interceptors.add(
//       PrettyDioLogger(
//         requestHeader: true,
//         requestBody: true,
//         responseHeader: true,
//         responseBody: true,
//         error: true,
//         compact: false,
//       ),
//     );

//     // If authentication is required, add Authorization Header
//     if (tokenInterceptor) {
//       dio.interceptors.add(InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final supabase = Supabase.instance.client;
//           final token = supabase.auth.currentSession?.accessToken;

//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           handler.next(options);
//         },
//       ));
//     }

//     return dio;
//   }
// }
