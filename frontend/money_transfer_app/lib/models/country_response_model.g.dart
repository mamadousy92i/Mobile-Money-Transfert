// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryResponse _$CountryResponseFromJson(Map<String, dynamic> json) =>
    CountryResponse(
      total: (json['total'] as num).toInt(),
      pays: (json['pays'] as List<dynamic>)
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CountryResponseToJson(CountryResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'pays': instance.pays,
    };
