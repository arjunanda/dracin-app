import 'package:dio/dio.dart';
import '../models/watchlist_item_model.dart';
import '../../../core/network/models/api_response.dart';

class WatchlistService {
  final Dio _dio;

  WatchlistService(this._dio);

  Future<ApiResponse<List<WatchlistItem>>> getWatchlist() async {
    final response = await _dio.get('me/watchlist');
    return ApiResponse<List<WatchlistItem>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => WatchlistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<void>> addToWatchlist(String seriesId) async {
    final response = await _dio.post('series/$seriesId/love');
    return ApiResponse<void>.fromJson(response.data, (json) => null);
  }

  Future<ApiResponse<void>> removeFromWatchlist(String seriesId) async {
    final response = await _dio.delete('series/$seriesId/love');
    return ApiResponse<void>.fromJson(response.data, (json) => null);
  }
}
