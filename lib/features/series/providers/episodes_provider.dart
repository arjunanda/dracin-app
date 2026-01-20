import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import '../services/series_service.dart';
import '../../home/providers/series_provider.dart';

final episodesProvider =
    StateNotifierProvider.family<EpisodesNotifier, List<Episode>, String>((
      ref,
      seriesId,
    ) {
      final service = ref.read(seriesServiceProvider);
      return EpisodesNotifier(service, seriesId);
    });

class EpisodesNotifier extends StateNotifier<List<Episode>> {
  final SeriesService _service;
  final String _seriesId;

  EpisodesNotifier(this._service, this._seriesId) : super([]) {
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    try {
      final response = await _service.getEpisodes(_seriesId);
      final episodes = response.data ?? [];
      // Ensure sorted by episode_number ASC
      episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      state = episodes;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleLike(String episodeId) async {
    final index = state.indexWhere((e) => e.id == episodeId);
    if (index == -1) return;

    final episode = state[index];
    final isLiked = !episode.isLiked;
    final newLikeCount = isLiked
        ? episode.likeCount + 1
        : episode.likeCount - 1;

    // Optimistic UI update
    final newState = [...state];
    newState[index] = episode.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount < 0 ? 0 : newLikeCount,
    );
    state = newState;

    try {
      await _service.likeEpisode(episodeId);
    } catch (e) {
      // Rollback on error
      state = [...state]..[index] = episode;
    }
  }

  Future<void> recordView(String episodeId, String deviceId) async {
    try {
      await _service.recordEpisodeView(episodeId, deviceId);
    } catch (e) {
      // Silently fail for views
    }
  }
}

final fypEpisodesProvider =
    StateNotifierProvider<FypEpisodesNotifier, List<Episode>>((ref) {
      final service = ref.read(seriesServiceProvider);
      return FypEpisodesNotifier(service);
    });

class FypEpisodesNotifier extends StateNotifier<List<Episode>> {
  final SeriesService _service;

  FypEpisodesNotifier(this._service) : super([]) {
    loadFypEpisodes();
  }

  Future<void> loadFypEpisodes() async {
    try {
      final response = await _service.getFypEpisodes();
      state = response.data ?? [];
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleLike(String episodeId) async {
    final index = state.indexWhere((e) => e.id == episodeId);
    if (index == -1) return;

    final episode = state[index];
    final isLiked = !episode.isLiked;
    final newLikeCount = isLiked
        ? episode.likeCount + 1
        : episode.likeCount - 1;

    // Optimistic UI update
    final newState = [...state];
    newState[index] = episode.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount < 0 ? 0 : newLikeCount,
    );
    state = newState;

    try {
      await _service.likeEpisode(episodeId);
    } catch (e) {
      // Rollback on error
      state = [...state]..[index] = episode;
    }
  }

  Future<void> recordView(String episodeId, String deviceId) async {
    try {
      await _service.recordEpisodeView(episodeId, deviceId);
    } catch (e) {
      // Silently fail for views
    }
  }
}
