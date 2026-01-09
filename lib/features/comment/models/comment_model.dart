import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  @JsonKey(name: 'series_id')
  final String seriesId;
  @JsonKey(name: 'user_name')
  final String userName;
  @JsonKey(name: 'user_avatar')
  final String? userAvatar;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.seriesId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
