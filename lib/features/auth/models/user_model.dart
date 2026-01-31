import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  @JsonKey(name: 'is_premium', defaultValue: false)
  final bool isPremium;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.isPremium = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
