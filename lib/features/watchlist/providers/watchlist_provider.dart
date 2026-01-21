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
    try {
      final response = await _service.getWatchlist();
      state = AsyncValue.data(response.data ?? []);

      debugPrint(response.data.toString());
    } catch (e, stack) {
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
