import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../core/network/models/api_response.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _dio.post(
      'auth/google/login',
      data: {'id_token': idToken},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<User?> getMe() async {
    final response = await _dio.get('me');
    final apiResponse = ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data;
  }
}
