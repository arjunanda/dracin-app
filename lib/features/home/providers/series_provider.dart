import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/series_model.dart';
import '../services/series_service.dart';

final seriesServiceProvider = Provider<SeriesService>((ref) {
  final dio = ref.read(apiClientProvider);
  return SeriesService(dio);
});

class SeriesListState {
  final List<Series> series;
  final bool isLoading;
  final bool hasMore;
  final int page;

  SeriesListState({
    this.series = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
  });

  SeriesListState copyWith({
    List<Series>? series,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return SeriesListState(
      series: series ?? this.series,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

final seriesProvider = StateNotifierProvider<SeriesNotifier, SeriesListState>((
  ref,
) {
  final service = ref.read(seriesServiceProvider);
  return SeriesNotifier(service);
});

class SeriesNotifier extends StateNotifier<SeriesListState> {
  final SeriesService _service;

  SeriesNotifier(this._service) : super(SeriesListState()) {
    getSeries();
  }

  Future<void> getSeries({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        series: [],
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final newSeries = await _service.getSeries(page: state.page);
      state = state.copyWith(
        series: [...state.series, ...newSeries],
        isLoading: false,
        hasMore: newSeries.isNotEmpty,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
