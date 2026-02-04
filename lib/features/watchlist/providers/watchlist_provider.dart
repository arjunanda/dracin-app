import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/watchlist_service.dart';
import '../models/watchlist_item_model.dart';
import '../../home/models/series_model.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  final dio = ref.read(apiClientProvider);
  return WatchlistService(dio);
});

final myWatchlistProvider =
    StateNotifierProvider<WatchlistNotifier, AsyncValue<List<WatchlistItem>>>((
      ref,
    ) {
      final authState = ref.watch(authProvider);
      final service = ref.read(watchlistServiceProvider);

      if (authState.status != AuthStatus.authenticated) {
        return WatchlistNotifier(service, shouldLoad: false);
      }

      return WatchlistNotifier(service);
    });

class WatchlistNotifier extends StateNotifier<AsyncValue<List<WatchlistItem>>> {
  final WatchlistService _service;

  WatchlistNotifier(this._service, {bool shouldLoad = true})
    : super(const AsyncValue.loading()) {
    if (shouldLoad) {
      loadWatchlist();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    debugPrint('DEBUG_WATCHLIST: Loading watchlist data...');
    try {
      final response = await _service.getWatchlist();
      final items = response.data ?? [];

      debugPrint('DEBUG_WATCHLIST: Success! Received ${items} items');
      for (var item in items) {
        debugPrint(
          'DEBUG_WATCHLIST_ITEM: Title: ${item.series.title}, ID: ${item.series.watchedEpisodesCount}',
        );
      }

      if (!mounted) return;
      state = AsyncValue.data(items);
    } catch (e, stack) {
      debugPrint('DEBUG_WATCHLIST: Error loading watchlist: $e');
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToWatchlist(Series series) async {
    try {
      await _service.addToWatchlist(series.id);
      await loadWatchlist();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeFromWatchlist(String seriesId) async {
    try {
      await _service.removeFromWatchlist(seriesId);
      if (!mounted) return;
      state.whenData((list) {
        state = AsyncValue.data(
          list.where((item) => item.seriesId != seriesId).toList(),
        );
      });
    } catch (e) {
      // Handle error
    }
  }

  bool isInWatchlist(String seriesId) {
    return state.maybeWhen(
      data: (list) => list.any((item) => item.seriesId == seriesId),
      orElse: () => false,
    );
  }
}
