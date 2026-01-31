import 'package:json_annotation/json_annotation.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class Rendition {
  final String resolution;
  final int bandwidth;
  final String url;

  Rendition({
    required this.resolution,
    required this.bandwidth,
    required this.url,
  });

  factory Rendition.fromJson(Map<String, dynamic> json) =>
      _$RenditionFromJson(json);
  Map<String, dynamic> toJson() => _$RenditionToJson(this);
}

@JsonSerializable()
class EpisodeSubtitle {
  final String file;
  final String lang;

  EpisodeSubtitle({required this.file, required this.lang});

  factory EpisodeSubtitle.fromJson(Map<String, dynamic> json) =>
      _$EpisodeSubtitleFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeSubtitleToJson(this);
}

@JsonSerializable()
class Episode {
  final String id;
  @JsonKey(name: 'series_id')
  final String seriesId;
  @JsonKey(name: 'episode_number')
  final int episodeNumber;
  final String title;
  final String description;
  @JsonKey(name: 'hls_master_url')
  final String hlsMasterUrl;
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  final String status;
  @JsonKey(name: 'view_count')
  final int viewCount;
  final List<Rendition> renditions;
  final List<EpisodeSubtitle> subtitles;
  @JsonKey(name: 'like_count')
  final int likeCount;
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  // Parent Series Metadata (useful for FYP)
  @JsonKey(name: 'series_title')
  final String? seriesTitle;
  @JsonKey(name: 'episodes_count')
  final int? episodesCount;
  @JsonKey(name: 'series_banner_url')
  final String? seriesBannerUrl;
  @JsonKey(name: 'series_name')
  final String? seriesName;
  @JsonKey(name: 'is_premium', defaultValue: false)
  final bool isPremium;

  Episode({
    required this.id,
    required this.seriesId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.hlsMasterUrl,
    required this.thumbnailUrl,
    required this.status,
    required this.viewCount,
    required this.renditions,
    required this.subtitles,
    required this.likeCount,
    required this.isLiked,
    this.seriesTitle,
    this.episodesCount,
    this.seriesBannerUrl,
    this.seriesName,
    this.isPremium = false,
  });

  String get effectiveSeriesTitle => seriesName ?? seriesTitle ?? '';

  Episode copyWith({
    String? id,
    String? seriesId,
    int? episodeNumber,
    String? title,
    String? description,
    String? hlsMasterUrl,
    String? thumbnailUrl,
    String? status,
    int? viewCount,
    List<Rendition>? renditions,
    List<EpisodeSubtitle>? subtitles,
    int? likeCount,
    bool? isLiked,
    String? seriesTitle,
    int? episodesCount,
    String? seriesBannerUrl,
    String? seriesName,
    bool? isPremium,
  }) {
    return Episode(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      hlsMasterUrl: hlsMasterUrl ?? this.hlsMasterUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      renditions: renditions ?? this.renditions,
      subtitles: subtitles ?? this.subtitles,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      episodesCount: episodesCount ?? this.episodesCount,
      seriesBannerUrl: seriesBannerUrl ?? this.seriesBannerUrl,
      seriesName: seriesName ?? this.seriesName,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}
