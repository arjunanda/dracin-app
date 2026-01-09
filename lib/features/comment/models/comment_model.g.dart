// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String,
  seriesId: json['series_id'] as String,
  userName: json['user_name'] as String,
  userAvatar: json['user_avatar'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'series_id': instance.seriesId,
  'user_name': instance.userName,
  'user_avatar': instance.userAvatar,
  'content': instance.content,
  'created_at': instance.createdAt.toIso8601String(),
};
