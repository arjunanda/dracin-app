import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_interceptor.dart';
import '../utils/secure_storage.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://217.217.255.44:8080/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  final storage = SecureStorage();

  // Create interceptor with unauthorized callback
  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () {
        // Just clear storage. The next time the app tries to use the token,
        // it will realize it's gone.
        storage.deleteToken();
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});
