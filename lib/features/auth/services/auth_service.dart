import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _dio.post(
      '/api/login/google',
      data: {'idToken': idToken},
    );
    return response.data;
  }

  Future<User> getMe() async {
    final response = await _dio.get('/api/me');
    return User.fromJson(response.data);
  }
}
