// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      code: json['code'] as String?,
      nom: json['nom'] as String?,
      devise: json['devise'] as String?,
      flag: json['flag'] as String?,
      prefixeTel: json['prefix_tel'] as String?,
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'code': instance.code,
      'nom': instance.nom,
      'devise': instance.devise,
      'flag': instance.flag,
      'prefix_tel': instance.prefixeTel,
    };
