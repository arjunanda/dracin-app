import 'package:json_annotation/json_annotation.dart';
import 'package:dracin_app/features/home/models/series_model.dart';

part 'watchlist_item_model.g.dart';

@JsonSerializable()
class WatchlistItem {
  final String id;
  @JsonKey(name: 'series_id')
  final String seriesId;
  @JsonKey(name: 'user_id')
  final String userId;
  final Series series;
  @JsonKey(name: 'created_at')
  final String createdAt;

  WatchlistItem({
    required this.id,
    required this.seriesId,
    required this.userId,
    required this.series,
    required this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistItemToJson(this);
}
