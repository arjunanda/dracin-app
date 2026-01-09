import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_interceptor.dart';
import '../utils/secure_storage.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  final storage = SecureStorage();
  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
});
