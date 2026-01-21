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
  final bool isLoved;
  final Category? category;
  final String? status;

  Series({
    required this.id,
    required this.title,
    this.description = '',
    this.bannerUrl = '',
    this.episodesCount,
    this.isLoved = false,
    this.category,
    this.status,
  });

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
  Map<String, dynamic> toJson() => _$SeriesToJson(this);
}
