// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
  id: json['id'] as String,
  seriesId: json['series_id'] as String,
  episodeNumber: (json['episode_number'] as num).toInt(),
  title: json['title'] as String,
  videoUrl: json['video_url'] as String,
  duration: (json['duration'] as num?)?.toInt(),
  isWatched: json['isWatched'] as bool? ?? false,
);

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
  'id': instance.id,
  'series_id': instance.seriesId,
  'episode_number': instance.episodeNumber,
  'title': instance.title,
  'video_url': instance.videoUrl,
  'duration': instance.duration,
  'isWatched': instance.isWatched,
};
