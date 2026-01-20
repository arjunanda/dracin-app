import 'package:dio/dio.dart';
import '../../../core/network/models/api_response.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio _dio;

  CategoryService(this._dio);

  Future<ApiResponse<List<Category>>> getCategories() async {
    final response = await _dio.get('categories');
    return ApiResponse<List<Category>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
