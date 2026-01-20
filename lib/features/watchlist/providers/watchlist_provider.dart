import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/watchlist_service.dart';
import '../../home/models/series_model.dart';
import '../../../core/network/api_client.dart';

final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  final dio = ref.read(apiClientProvider);
  return WatchlistService(dio);
});

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Series>>>((ref) {
      final service = ref.read(watchlistServiceProvider);
      return WatchlistNotifier(service);
    });

class WatchlistNotifier extends StateNotifier<AsyncValue<List<Series>>> {
  final WatchlistService _service;

  WatchlistNotifier(this._service) : super(const AsyncValue.loading()) {
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    try {
      final response = await _service.getWatchlist();
      state = AsyncValue.data(response.data ?? []);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addToWatchlist(Series series) async {
    try {
      await _service.addToWatchlist(series.id);
      state.whenData((list) {
        if (!list.any((item) => item.id == series.id)) {
          state = AsyncValue.data([...list, series]);
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeFromWatchlist(String seriesId) async {
    try {
      await _service.removeFromWatchlist(seriesId);
      state.whenData((list) {
        state = AsyncValue.data(
          list.where((item) => item.id != seriesId).toList(),
        );
      });
    } catch (e) {
      // Handle error
    }
  }

  bool isInWatchlist(String seriesId) {
    return state.when(
      data: (list) => list.any((item) => item.id == seriesId),
      loading: () => false,
      error: (_, __) => false,
    );
  }
}
