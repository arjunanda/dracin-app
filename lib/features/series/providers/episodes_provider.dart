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
}
