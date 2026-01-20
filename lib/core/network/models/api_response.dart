import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({this.success = true, this.message = '', this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginationData<T> {
  final List<T> data;
  final int page;
  @JsonKey(name: 'page_size')
  final int pageSize;
  final int total;

  PaginationData({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PaginationData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginationDataFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginationDataToJson(this, toJsonT);
}
