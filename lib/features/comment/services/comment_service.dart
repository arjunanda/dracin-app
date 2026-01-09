import 'package:dio/dio.dart';
import '../models/comment_model.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  Future<List<Comment>> getComments(
    String seriesId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      '/api/series/$seriesId/comments',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Comment.fromJson(json)).toList();
  }

  Future<void> postComment(String seriesId, String content) async {
    await _dio.post(
      '/api/series/$seriesId/comments',
      data: {'content': content},
    );
  }
}
