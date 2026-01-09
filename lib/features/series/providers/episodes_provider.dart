import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';
import '../../home/services/series_service.dart';
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
      final episodes = await _service.getEpisodes(_seriesId);
      // Ensure sorted by episode_number ASC
      episodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      state = episodes;
    } catch (e) {
      // Handle error
    }
  }
}
