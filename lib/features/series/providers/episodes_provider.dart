import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import '../services/series_service.dart';
import '../../home/providers/series_provider.dart';
import '../../../core/utils/secure_storage.dart';

final episodesProvider =
    StateNotifierProvider.family<EpisodesNotifier, List<Episode>, String>((
      ref,
      seriesId,
    ) {
      final service = ref.read(seriesServiceProvider);
      final storage = ref.read(secureStorageProvider);
      return EpisodesNotifier(service, storage, seriesId);
    });

class EpisodesNotifier extends StateNotifier<List<Episode>> {
  final SeriesService _service;
  final SecureStorage _storage;
  final String _seriesId;
  final Set<String> _pendingLikeIds = {};
  final Map<String, DateTime> _lastLikeActionTimes = {};

  EpisodesNotifier(this._service, this._storage, this._seriesId) : super([]) {
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
    if (_pendingLikeIds.contains(episodeId)) {
      print('⏳ Like already pending for $episodeId, ignoring');
      return;
    }

    final index = state.indexWhere((e) => e.id == episodeId);
    if (index == -1) return;

    _pendingLikeIds.add(episodeId);
    _lastLikeActionTimes[episodeId] = DateTime.now();

    final episode = state[index];
    final isLiked = !episode.isLiked;
    final newLikeCount = isLiked
        ? episode.likeCount + 1
        : episode.likeCount - 1;

    print('❤️ Optimistic Like: $episodeId -> $isLiked (Count: $newLikeCount)');

    // Optimistic UI update
    final newState = [...state];
    newState[index] = episode.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount < 0 ? 0 : newLikeCount,
    );
    state = newState;

    try {
      final token = await _storage.getToken();
      await _service.likeEpisode(episodeId, token);
      print('✅ Like API Success for $episodeId');
      // Keep in pending for a bit to allow backend cache to sync
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      print('❌ Like API Error for $episodeId: $e');
      // Rollback on error
      if (mounted) {
        final rollbackIndex = state.indexWhere((e) => e.id == episodeId);
        if (rollbackIndex != -1) {
          final rollbackState = [...state];
          rollbackState[rollbackIndex] = episode;
          state = rollbackState;
        }
      }
    } finally {
      _pendingLikeIds.remove(episodeId);
    }
  }

  Future<void> recordView(String episodeId, String deviceId) async {
    try {
      await _service.recordEpisodeView(episodeId, deviceId);
    } catch (e) {
      // Silently fail for views
    }
  }

  Future<void> refreshLikeStatus(String episodeId) async {
    // Check if we recently liked this episode
    final lastAction = _lastLikeActionTimes[episodeId];
    if (lastAction != null &&
        DateTime.now().difference(lastAction).inSeconds < 5) {
      print('🛡️ Skipping refresh for $episodeId (Cooldown active)');
      return;
    }

    if (_pendingLikeIds.contains(episodeId)) return;

    try {
      print('🔄 Fetching latest like status for $episodeId');
      final token = await _storage.getToken();
      final response = await _service.getEpisodeLikeStatus(episodeId, token);

      print('📊 SERVER_RESPONSE (Episodes) for $episodeId: ${response.data}');

      // Double check after network call returns
      if (_pendingLikeIds.contains(episodeId)) return;
      final lastActionAfter = _lastLikeActionTimes[episodeId];
      if (lastActionAfter != null &&
          DateTime.now().difference(lastActionAfter).inSeconds < 5)
        return;

      final data = response.data;
      if (data != null) {
        final isLiked = data['is_liked'] ?? false;
        final likeCount = data['like_count'] ?? 0;
        print(
          '📊 Server Status for $episodeId: isLiked=$isLiked, count=$likeCount',
        );

        final index = state.indexWhere((e) => e.id == episodeId);
        if (index != -1) {
          // Only update if it's actually different to avoid unnecessary rebuilds
          if (state[index].isLiked != isLiked ||
              state[index].likeCount != likeCount) {
            final newState = [...state];
            newState[index] = state[index].copyWith(
              isLiked: isLiked,
              likeCount: likeCount,
            );
            state = newState;
          }
        }
      }
    } catch (e) {
      print('⚠️ Error refreshing like status for $episodeId: $e');
    }
  }
}

final fypEpisodesProvider =
    StateNotifierProvider<FypEpisodesNotifier, List<Episode>>((ref) {
      final service = ref.read(seriesServiceProvider);
      final storage = ref.read(secureStorageProvider);
      return FypEpisodesNotifier(service, storage);
    });

class FypEpisodesNotifier extends StateNotifier<List<Episode>> {
  final SeriesService _service;
  final SecureStorage _storage;
  final Set<String> _pendingLikeIds = {};
  final Map<String, DateTime> _lastLikeActionTimes = {};

  int _page = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  FypEpisodesNotifier(this._service, this._storage) : super([]) {
    loadFypEpisodes();
  }

  Future<void> loadFypEpisodes() async {
    _page = 1;
    _hasMore = true;
    try {
      final response = await _service.getFypEpisodes(page: _page);
      final newEpisodes = response.data ?? [];
      if (newEpisodes.isEmpty) _hasMore = false;
      state = newEpisodes;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadMoreFypEpisodes() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      final nextPage = _page + 1;
      final response = await _service.getFypEpisodes(page: nextPage);
      final newEpisodes = response.data ?? [];

      if (newEpisodes.isEmpty) {
        _hasMore = false;
      } else {
        _page = nextPage;
        state = [...state, ...newEpisodes];
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> toggleLike(String episodeId) async {
    if (_pendingLikeIds.contains(episodeId)) {
      print('⏳ Like already pending for $episodeId, ignoring');
      return;
    }

    final index = state.indexWhere((e) => e.id == episodeId);
    if (index == -1) return;

    _pendingLikeIds.add(episodeId);
    _lastLikeActionTimes[episodeId] = DateTime.now();

    final episode = state[index];
    final isLiked = !episode.isLiked;
    final newLikeCount = isLiked
        ? episode.likeCount + 1
        : episode.likeCount - 1;

    print('❤️ Optimistic Like: $episodeId -> $isLiked (Count: $newLikeCount)');

    // Optimistic UI update
    final newState = [...state];
    newState[index] = episode.copyWith(
      isLiked: isLiked,
      likeCount: newLikeCount < 0 ? 0 : newLikeCount,
    );
    state = newState;

    try {
      final token = await _storage.getToken();
      await _service.likeEpisode(episodeId, token);
      print('✅ Like API Success for $episodeId');
      // Keep in pending for a bit to allow backend cache to sync
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      print('❌ Like API Error for $episodeId: $e');
      // Rollback on error
      if (mounted) {
        final rollbackIndex = state.indexWhere((e) => e.id == episodeId);
        if (rollbackIndex != -1) {
          final rollbackState = [...state];
          rollbackState[rollbackIndex] = episode;
          state = rollbackState;
        }
      }
    } finally {
      _pendingLikeIds.remove(episodeId);
    }
  }

  Future<void> recordView(String episodeId, String deviceId) async {
    try {
      await _service.recordEpisodeView(episodeId, deviceId);
    } catch (e) {
      // Silently fail for views
    }
  }

  Future<void> refreshLikeStatus(String episodeId) async {
    // Check if we recently liked this episode
    final lastAction = _lastLikeActionTimes[episodeId];
    if (lastAction != null &&
        DateTime.now().difference(lastAction).inSeconds < 5) {
      print('🛡️ Skipping refresh for $episodeId (Cooldown active)');
      return;
    }

    if (_pendingLikeIds.contains(episodeId)) return;

    try {
      print('🔄 Fetching latest like status for $episodeId');
      final token = await _storage.getToken();
      final response = await _service.getEpisodeLikeStatus(episodeId, token);

      print('📊 SERVER_RESPONSE (FYP) for $episodeId: ${response.data}');

      // Double check after network call returns
      if (_pendingLikeIds.contains(episodeId)) return;
      final lastActionAfter = _lastLikeActionTimes[episodeId];
      if (lastActionAfter != null &&
          DateTime.now().difference(lastActionAfter).inSeconds < 5)
        return;

      final data = response.data;
      if (data != null) {
        final isLiked = data['is_liked'] ?? false;
        final likeCount = data['like_count'] ?? 0;
        print(
          '📊 Server Status for $episodeId: isLiked=$isLiked, count=$likeCount',
        );

        final index = state.indexWhere((e) => e.id == episodeId);
        if (index != -1) {
          // Only update if it's actually different to avoid unnecessary rebuilds
          if (state[index].isLiked != isLiked ||
              state[index].likeCount != likeCount) {
            final newState = [...state];
            newState[index] = state[index].copyWith(
              isLiked: isLiked,
              likeCount: likeCount,
            );
            state = newState;
          }
        }
      }
    } catch (e) {
      print('⚠️ Error refreshing like status for $episodeId: $e');
    }
  }
}
