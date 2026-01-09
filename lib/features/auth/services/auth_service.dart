import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(
      '/api/register',
      data: {'email': email, 'password': password, 'name': name},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<User> getMe() async {
    final response = await _dio.get('/api/me');
    return User.fromJson(response.data);
  }
}
