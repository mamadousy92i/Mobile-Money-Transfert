// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beneficiaire _$BeneficiaireFromJson(Map<String, dynamic> json) => Beneficiaire(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$BeneficiaireToJson(Beneficiaire instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
