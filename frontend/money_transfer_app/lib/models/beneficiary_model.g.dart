// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Beneficiary _$BeneficiaryFromJson(Map<String, dynamic> json) => Beneficiary(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$BeneficiaryToJson(Beneficiary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
    };
