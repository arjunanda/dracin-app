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
    String? currentType,
    String? categoryId,
  }) {
    return SeriesListState(
      series: series ?? this.series,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      currentType: currentType ?? this.currentType,
      categoryId: categoryId ?? this.categoryId,
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

    // If type or category is different, it's a refresh
    final isTypeChanged = type != null && type != state.currentType;
    final isCategoryChanged =
        categoryId != null && categoryId != state.categoryId;
    final shouldRefresh = refresh || isTypeChanged || isCategoryChanged;

    if (!shouldRefresh && !state.hasMore) return;

    if (shouldRefresh) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        series: [],
        hasMore: true,
        currentType: type ?? (isCategoryChanged ? null : state.currentType),
        categoryId: categoryId ?? (isTypeChanged ? null : state.categoryId),
      );
    } else {
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
