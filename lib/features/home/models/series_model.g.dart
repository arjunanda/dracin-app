// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Series _$SeriesFromJson(Map<String, dynamic> json) => Series(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  thumbnailUrl: json['thumbnail_url'] as String,
  episodesCount: (json['episodes_count'] as num).toInt(),
  isLoved: json['isLoved'] as bool? ?? false,
);

Map<String, dynamic> _$SeriesToJson(Series instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'thumbnail_url': instance.thumbnailUrl,
  'episodes_count': instance.episodesCount,
  'isLoved': instance.isLoved,
};
