import 'package:json_annotation/json_annotation.dart';
import 'category_model.dart';

part 'series_model.g.dart';

@JsonSerializable()
class Series {
  final String id;
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'banner_url', defaultValue: '')
  final String bannerUrl;
  @JsonKey(name: 'episodes_count')
  final int? episodesCount;
  @JsonKey(name: 'watched_episodes_count')
  final int? watchedEpisodesCount;
  final bool isLoved;
  final Category? category;
  final String? status;
  @JsonKey(name: 'last_watched_episode_id')
  final String? lastWatchedEpisodeId;

  Series({
    required this.id,
    required this.title,
    this.description = '',
    this.bannerUrl = '',
    this.episodesCount,
    this.watchedEpisodesCount,
    this.isLoved = false,
    this.category,
    this.status,
    this.lastWatchedEpisodeId,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
}
