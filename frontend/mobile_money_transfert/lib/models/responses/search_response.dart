// lib/models/responses/search_response.dart

import 'package:json_annotation/json_annotation.dart';
import '../transaction.dart';

part 'search_response.g.dart';

@JsonSerializable()
class SearchResponse {
  final String query;
  final int count;
  final List<Transaction> results;

  SearchResponse({
    required this.query,
    required this.count,
    required this.results,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  bool get hasResults => results.isNotEmpty;
  bool get isEmpty => results.isEmpty;
}