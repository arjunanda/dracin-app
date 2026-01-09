import 'package:json_annotation/json_annotation.dart';

part 'series_model.g.dart';

@JsonSerializable()
class Series {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  @JsonKey(name: 'episodes_count')
  final int episodesCount;
  final bool isLoved;

  Series({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.episodesCount,
    this.isLoved = false,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
}
