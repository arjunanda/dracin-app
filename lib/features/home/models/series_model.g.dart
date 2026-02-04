// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Series _$SeriesFromJson(Map<String, dynamic> json) => Series(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  bannerUrl: json['banner_url'] as String? ?? '',
  episodesCount: (json['episodes_count'] as num?)?.toInt(),
  watchedEpisodesCount: (json['watched_episodes_count'] as num?)?.toInt(),
  isLoved: json['isLoved'] as bool? ?? false,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  status: json['status'] as String?,
  lastWatchedEpisodeId: json['last_watched_episode_id'] as String?,
);

Map<String, dynamic> _$SeriesToJson(Series instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'banner_url': instance.bannerUrl,
  'episodes_count': instance.episodesCount,
  'watched_episodes_count': instance.watchedEpisodesCount,
  'isLoved': instance.isLoved,
  'category': instance.category,
  'status': instance.status,
  'last_watched_episode_id': instance.lastWatchedEpisodeId,
};
