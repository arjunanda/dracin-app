import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../core/network/models/api_response.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(
      'register',
      data: {'email': email, 'password': password, 'name': name},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      'login',
      data: {'email': email, 'password': password},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<User>> getMe() async {
    final response = await _dio.get('me');
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }
}
