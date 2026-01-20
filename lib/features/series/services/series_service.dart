import 'package:dio/dio.dart';
import '../../home/models/series_model.dart';
import '../models/episode_model.dart';
import '../../../core/network/models/api_response.dart';

class SeriesService {
  final Dio _dio;

  SeriesService(this._dio);

  Future<ApiResponse<PaginationData<Series>>> getSeriesList({
    int page = 1,
    int pageSize = 10,
    String? type,
    String? categoryId,
  }) async {
    final response = await _dio.get(
      'series',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'status': 'publish',
        if (type != null) 'type': type,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return ApiResponse<PaginationData<Series>>.fromJson(
      response.data,
      (json) => PaginationData<Series>.fromJson(
        json as Map<String, dynamic>,
        (itemJson) => Series.fromJson(itemJson as Map<String, dynamic>),
      ),
    );
  }

  Future<ApiResponse<Series>> getSeriesDetail(String id) async {
    final response = await _dio.get('series/$id');
    return ApiResponse<Series>.fromJson(
      response.data,
      (json) => Series.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<Episode>>> getEpisodes(String seriesId) async {
    final response = await _dio.get('series/$seriesId/episodes');
    return ApiResponse<List<Episode>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Episode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Episode>>> getFypEpisodes() async {
    final response = await _dio.get('fyp');
    return ApiResponse<List<Episode>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Episode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<void>> toggleLove(String id, bool love) async {
    final response = await _dio.post('series/$id/love', data: {'love': love});
    return ApiResponse<void>.fromJson(response.data, (json) => null);
  }
}
