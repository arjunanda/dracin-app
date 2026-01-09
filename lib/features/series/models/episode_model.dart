import 'package:json_annotation/json_annotation.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class Episode {
  final String id;
  @JsonKey(name: 'series_id')
  final String seriesId;
  @JsonKey(name: 'episode_number')
  final int episodeNumber;
  final String title;
  @JsonKey(name: 'video_url')
  final String videoUrl; // HLS master.m3u8
  final int? duration; // In seconds
  final bool isWatched;

  Episode({
    required this.id,
    required this.seriesId,
    required this.episodeNumber,
    required this.title,
    required this.videoUrl,
    this.duration,
    this.isWatched = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}
