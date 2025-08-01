// lib/models/paginated_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart'; // <-- AJOUTEZ CETTE LIGNE

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int count;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}