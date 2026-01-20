import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/series_model.dart';
import '../../series/services/series_service.dart';
import '../../../core/network/api_client.dart';

final seriesServiceProvider = Provider<SeriesService>((ref) {
  final dio = ref.read(apiClientProvider);
  return SeriesService(dio);
});

class SeriesListState {
  final List<Series> series;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? currentType;
  final String? categoryId;

  SeriesListState({
    this.series = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.currentType,
    this.categoryId,
  });

  SeriesListState copyWith({
    List<Series>? series,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? Function()? currentType,
    String? Function()? categoryId,
  }) {
    return SeriesListState(
      series: series ?? this.series,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      currentType: currentType != null ? currentType() : this.currentType,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
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
    getSeries(type: 'popular');
  }

  Future<void> getSeries({
    bool refresh = false,
    String? type,
    String? categoryId,
  }) async {
    if (state.isLoading) return;

    // Reset pagination and clear list if filter changes or explicitly refreshing
    final isFilterChanging = type != null || categoryId != null;
    final shouldReset = refresh || isFilterChanging;

    if (shouldReset) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        series: [],
        hasMore: true,
        // If type is coming in, clear categoryId.
        // If categoryId is coming in, clear type.
        // If it's a generic refresh, keep what we have.
        currentType: type != null
            ? () => type
            : (categoryId != null ? () => null : null),
        categoryId: categoryId != null
            ? () => categoryId
            : (type != null ? () => null : null),
      );
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _service.getSeriesList(
        page: state.page,
        type: state.currentType,
        categoryId: state.categoryId,
      );

      final paginationData = response.data;

      if (paginationData != null) {
        final newSeries = paginationData.data;
        state = state.copyWith(
          series: [...state.series, ...newSeries],
          isLoading: false,
          hasMore: state.page * paginationData.pageSize < paginationData.total,
          page: state.page + 1,
        );
      } else {
        state = state.copyWith(isLoading: false, hasMore: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
