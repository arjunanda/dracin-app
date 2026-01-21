// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rendition _$RenditionFromJson(Map<String, dynamic> json) => Rendition(
  resolution: json['resolution'] as String,
  bandwidth: (json['bandwidth'] as num).toInt(),
  url: json['url'] as String,
);

Map<String, dynamic> _$RenditionToJson(Rendition instance) => <String, dynamic>{
  'resolution': instance.resolution,
  'bandwidth': instance.bandwidth,
  'url': instance.url,
};

EpisodeSubtitle _$EpisodeSubtitleFromJson(Map<String, dynamic> json) =>
    EpisodeSubtitle(file: json['file'] as String, lang: json['lang'] as String);

Map<String, dynamic> _$EpisodeSubtitleToJson(EpisodeSubtitle instance) =>
    <String, dynamic>{'file': instance.file, 'lang': instance.lang};

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
  id: json['id'] as String,
  seriesId: json['series_id'] as String,
  episodeNumber: (json['episode_number'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  hlsMasterUrl: json['hls_master_url'] as String,
  thumbnailUrl: json['thumbnail_url'] as String,
  status: json['status'] as String,
  viewCount: (json['view_count'] as num).toInt(),
  renditions: (json['renditions'] as List<dynamic>)
      .map((e) => Rendition.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtitles: (json['subtitles'] as List<dynamic>)
      .map((e) => EpisodeSubtitle.fromJson(e as Map<String, dynamic>))
      .toList(),
  likeCount: (json['like_count'] as num).toInt(),
  isLiked: json['is_liked'] as bool,
  seriesTitle: json['series_title'] as String?,
  episodesCount: (json['episodes_count'] as num?)?.toInt(),
  seriesBannerUrl: json['series_banner_url'] as String?,
  seriesName: json['series_name'] as String?,
);

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
  'id': instance.id,
  'series_id': instance.seriesId,
  'episode_number': instance.episodeNumber,
  'title': instance.title,
  'description': instance.description,
  'hls_master_url': instance.hlsMasterUrl,
  'thumbnail_url': instance.thumbnailUrl,
  'status': instance.status,
  'view_count': instance.viewCount,
  'renditions': instance.renditions,
  'subtitles': instance.subtitles,
  'like_count': instance.likeCount,
  'is_liked': instance.isLiked,
  'series_title': instance.seriesTitle,
  'episodes_count': instance.episodesCount,
  'series_banner_url': instance.seriesBannerUrl,
  'series_name': instance.seriesName,
};
