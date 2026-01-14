import '../models/series_model.dart';
import '../../series/models/episode_model.dart';

/// Temporary stubbed service that returns dummy data instead of calling a
/// backend. This prevents network calls during development and shows
/// example content on the home screen.
class SeriesService {
  SeriesService();

  Future<List<Series>> getSeries({int page = 1, int pageSize = 10}) async {
    // Simulate small delay
    await Future.delayed(const Duration(milliseconds: 200));
    final start = (page - 1) * pageSize + 1;
    return List.generate(pageSize, (i) {
      final id = (start + i).toString();
      return Series(
        id: id,
        title: 'Sample Show $id',
        description:
            'A short description for sample show $id. Enjoy the preview!',
        thumbnailUrl: 'https://picsum.photos/seed/series_$id/800/1200',
        episodesCount: 8 + (i % 10),
        isLoved: false,
      );
    });
  }

  Future<Series> getSeriesById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Series(
      id: id,
      title: 'Sample Show $id',
      description: 'A short description for sample show $id. Full detail page.',
      thumbnailUrl: 'https://picsum.photos/seed/series_$id/800/1200',
      episodesCount: 12,
    );
  }

  Future<List<Episode>> getEpisodes(String seriesId) async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Public HLS test streams with multiple quality levels
    final hlsStreams = [
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', // Multi-bitrate HLS
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8', // Sintel
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8', // Apple test
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8', // Tears of Steel
      'https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8', // Big Buck Bunny HLS
    ];

    if (seriesId == 'fyp') {
      return List.generate(10, (i) {
        final randomSeriesId = (i + 100).toString();
        return Episode(
          id: 'fyp-$i',
          seriesId: randomSeriesId,
          title: 'FYP Video ${i + 1}: Trending Content',
          episodeNumber: i + 1,
          videoUrl: hlsStreams[i % hlsStreams.length],
        );
      });
    }

    return List.generate(6, (i) {
      return Episode(
        id: '$seriesId-ep-${i + 1}',
        seriesId: seriesId,
        title: 'Episode ${i + 1}',
        episodeNumber: i + 1,
        // Use HLS streams for adaptive quality
        videoUrl: hlsStreams[i % hlsStreams.length],
      );
    });
  }

  Future<void> toggleLove(String id, bool love) async {
    // no-op for stub
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
