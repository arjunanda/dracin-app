import 'package:dio/dio.dart';
import '../../home/models/series_model.dart';
import '../../../core/network/models/api_response.dart';

class WatchlistService {
  final Dio _dio;

  WatchlistService(this._dio);

  Future<ApiResponse<List<Series>>> getWatchlist() async {
    final response = await _dio.get('me/watchlist');
    return ApiResponse<List<Series>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Series.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<void>> addToWatchlist(String seriesId) async {
    final response = await _dio.post(
      'me/watchlist',
      data: {'series_id': seriesId},
    );
    return ApiResponse<void>.fromJson(response.data, (json) => null);
  }

  Future<ApiResponse<void>> removeFromWatchlist(String seriesId) async {
    final response = await _dio.delete('me/watchlist/$seriesId');
    return ApiResponse<void>.fromJson(response.data, (json) => null);
  }
}
