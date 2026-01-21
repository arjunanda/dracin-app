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
      response.data ?? {},
      (json) => PaginationData<Series>.fromJson(
        json as Map<String, dynamic>,
        (itemJson) => Series.fromJson(itemJson as Map<String, dynamic>),
      ),
    );
  }

  Future<ApiResponse<Series>> getSeriesDetail(String id) async {
    final response = await _dio.get('series/$id');
    return ApiResponse<Series>.fromJson(
      response.data ?? {},
      (json) => Series.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<Episode>>> getEpisodes(String seriesId) async {
    final response = await _dio.get('series/$seriesId/episodes');
    final data = response.data['data'];

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      // Nested PaginationData structure
      final apiResponse = ApiResponse<PaginationData<Episode>>.fromJson(
        response.data ?? {},
        (json) => PaginationData<Episode>.fromJson(
          json as Map<String, dynamic>,
          (itemJson) => Episode.fromJson(itemJson as Map<String, dynamic>),
        ),
      );
      return ApiResponse<List<Episode>>(
        success: apiResponse.success,
        message: apiResponse.message,
        data: apiResponse.data?.data,
      );
    } else {
      // Direct list structure
      return ApiResponse<List<Episode>>.fromJson(
        response.data ?? {},
        (json) => (json as List)
            .map((item) => Episode.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }
  }

  Future<ApiResponse<List<Episode>>> getFypEpisodes({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      'fyp',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = response.data['data'];

    final List<Episode> initialEpisodes;
    bool success = response.data['success'] ?? true;
    String message = response.data['message'] ?? '';

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final apiResponse = ApiResponse<PaginationData<Episode>>.fromJson(
        response.data ?? {},
        (json) => PaginationData<Episode>.fromJson(
          json as Map<String, dynamic>,
          (itemJson) => Episode.fromJson(itemJson as Map<String, dynamic>),
        ),
      );
      initialEpisodes = apiResponse.data?.data ?? [];
      success = apiResponse.success;
      message = apiResponse.message;
    } else {
      final apiResponse = ApiResponse<List<Episode>>.fromJson(
        response.data ?? {},
        (json) => (json as List)
            .map((item) => Episode.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      initialEpisodes = apiResponse.data ?? [];
      success = apiResponse.success;
      message = apiResponse.message;
    }

    final List<Episode> enrichedEpisodes = [];
    final Map<String, Series?> seriesCache = {};

    for (var fypEpisode in initialEpisodes) {
      try {
        Series? series;
        if (seriesCache.containsKey(fypEpisode.seriesId)) {
          series = seriesCache[fypEpisode.seriesId];
        } else {
          final seriesResponse = await getSeriesDetail(fypEpisode.seriesId);
          series = seriesResponse.data;
          seriesCache[fypEpisode.seriesId] = series;
        }

        enrichedEpisodes.add(
          fypEpisode.copyWith(
            seriesTitle: series?.title,
            seriesBannerUrl: series?.bannerUrl,
            episodesCount: series?.episodesCount,
          ),
        );
      } catch (e) {
        enrichedEpisodes.add(fypEpisode);
      }
    }

    return ApiResponse<List<Episode>>(
      success: success,
      message: message,
      data: enrichedEpisodes,
    );
  }

  Future<ApiResponse<void>> toggleLove(String id, bool love) async {
    final response = love
        ? await _dio.post('series/$id/love')
        : await _dio.delete('series/$id/love');
    return ApiResponse<void>.fromJson(response.data ?? {}, (json) {});
  }

  Future<ApiResponse<bool>> getWatchlistStatus(String id) async {
    try {
      final response = await _dio.get('series/$id/watchlist-status');
      return ApiResponse<bool>.fromJson(
        response.data ?? {},
        (json) =>
            (json as Map<String, dynamic>)['in_watchlist'] as bool? ?? false,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: e.toString(),
        data: false,
      );
    }
  }

  Future<ApiResponse<void>> likeEpisode(
    String episodeId, [
    String? token,
  ]) async {
    final response = await _dio.post(
      'episodes/$episodeId/like',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return ApiResponse<void>.fromJson(response.data ?? {}, (json) {});
  }

  Future<ApiResponse<Map<String, dynamic>>> getEpisodeLikeStatus(
    String episodeId, [
    String? token,
  ]) async {
    final response = await _dio.get(
      'episodes/$episodeId/likes',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data ?? {},
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<void>> recordEpisodeView(
    String episodeId,
    String deviceId,
  ) async {
    final response = await _dio.post(
      'episodes/$episodeId/view',
      data: {'device_id': deviceId},
    );
    return ApiResponse<void>.fromJson(response.data ?? {}, (json) {});
  }
}
