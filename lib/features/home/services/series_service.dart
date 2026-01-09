import 'package:dio/dio.dart';
import '../models/series_model.dart';
import '../../series/models/episode_model.dart';

class SeriesService {
  final Dio _dio;

  SeriesService(this._dio);

  Future<List<Series>> getSeries({int page = 1, int pageSize = 10}) async {
    final response = await _dio.get(
      '/api/series',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Series.fromJson(json)).toList();
  }

  Future<Series> getSeriesById(String id) async {
    final response = await _dio.get('/api/series/$id');
    return Series.fromJson(response.data);
  }

  Future<List<Episode>> getEpisodes(String seriesId) async {
    final response = await _dio.get('/api/series/$seriesId/episodes');
    final List<dynamic> data = response.data;
    return data.map((json) => Episode.fromJson(json)).toList();
  }

  Future<void> toggleLove(String id, bool love) async {
    if (love) {
      await _dio.post('/api/series/$id/love');
    } else {
      await _dio.delete('/api/series/$id/love');
    }
  }
}
