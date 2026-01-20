import 'package:dio/dio.dart';
import '../../home/models/series_model.dart';
import '../../../core/network/models/api_response.dart';

class SeriesService {
  final Dio _dio;

  SeriesService(this._dio);

  Future<ApiResponse<PaginationData<Series>>> getSeriesList({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      'series',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
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
}
