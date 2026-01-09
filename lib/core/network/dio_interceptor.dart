import 'package:dio/dio.dart';
import '../utils/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

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
      // Handle logout or token refresh if needed
      _storage.deleteToken();
    }
    return handler.next(err);
  }
}
