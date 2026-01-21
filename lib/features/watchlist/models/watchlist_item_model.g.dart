// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchlistItem _$WatchlistItemFromJson(Map<String, dynamic> json) =>
    WatchlistItem(
      id: json['id'] as String,
      seriesId: json['series_id'] as String,
      userId: json['user_id'] as String,
      series: Series.fromJson(json['series'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$WatchlistItemToJson(WatchlistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'series_id': instance.seriesId,
      'user_id': instance.userId,
      'series': instance.series,
      'created_at': instance.createdAt,
    };
