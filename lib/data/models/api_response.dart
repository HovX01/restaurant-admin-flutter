import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API Response wrapper as defined in the documentation
/// All API responses follow this consistent format
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// Paginated response wrapper for list endpoints
@JsonSerializable(genericArgumentFactories: true)
class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PagedResponseToJson(this, toJsonT);
}
