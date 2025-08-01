// lib/models/country_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'country_model.dart';

part 'country_response_model.g.dart';

@JsonSerializable()
class CountryResponse {
  final int total;
  final List<Country> pays;

  CountryResponse({required this.total, required this.pays});

  factory CountryResponse.fromJson(Map<String, dynamic> json) =>
      _$CountryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CountryResponseToJson(this);
}