import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../../../core/network/api_client.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final dio = ref.read(apiClientProvider);
  return CategoryService(dio);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.read(categoryServiceProvider);
  final response = await service.getCategories();
  return response.data ?? [];
});
