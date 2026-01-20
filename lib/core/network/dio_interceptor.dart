import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final VoidCallback? onUnauthorized;

  AuthInterceptor(this._storage, {this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.deleteToken();
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}

typedef VoidCallback = void Function();
