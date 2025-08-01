// lib/models/country_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'country_model.g.dart';

@JsonSerializable()
class Country {
  final String? code;
  final String? nom;
  final String? devise;
  final String? flag;
  @JsonKey(name: 'prefix_tel') // <-- 'e' retiré pour correspondre au JSON
  final String? prefixeTel;

  Country({
    this.code,
    this.nom,
    this.devise,
    this.flag,
    this.prefixeTel,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}