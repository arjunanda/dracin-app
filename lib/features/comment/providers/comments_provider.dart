import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

final commentServiceProvider = Provider<CommentService>((ref) {
  final dio = ref.read(apiClientProvider);
  return CommentService(dio);
});

class CommentListState {
  final List<Comment> comments;
  final bool isLoading;
  final bool hasMore;
  final int page;

  CommentListState({
    this.comments = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
  });

  CommentListState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return CommentListState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentListState, String>((
      ref,
      seriesId,
    ) {
      final service = ref.read(commentServiceProvider);
      return CommentsNotifier(service, seriesId);
    });

class CommentsNotifier extends StateNotifier<CommentListState> {
  final CommentService _service;
  final String _seriesId;

  CommentsNotifier(this._service, this._seriesId) : super(CommentListState()) {
    getComments();
  }

  Future<void> getComments({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        comments: [],
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final newComments = await _service.getComments(
        _seriesId,
        page: state.page,
      );
      state = state.copyWith(
        comments: [...state.comments, ...newComments],
        isLoading: false,
        hasMore: newComments.isNotEmpty,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> postComment(String content) async {
    try {
      await _service.postComment(_seriesId, content);
      getComments(refresh: true);
    } catch (e) {
      // Handle error
    }
  }
}
