// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canal_paiement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanalPaiement _$CanalPaiementFromJson(Map<String, dynamic> json) =>
    CanalPaiement(
      id: json['id'] as String,
      canalName: json['canal_name'] as String,
      typeCanal: json['type_canal'] as String,
      isActive: json['is_active'] as bool,
      country: json['country'] as String,
      feesPercentage: (json['fees_percentage'] as num).toDouble(),
      feesFixed: (json['fees_fixed'] as num).toDouble(),
      minAmount: (json['min_amount'] as num).toDouble(),
      maxAmount: (json['max_amount'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$CanalPaiementToJson(CanalPaiement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'canal_name': instance.canalName,
      'type_canal': instance.typeCanal,
      'is_active': instance.isActive,
      'country': instance.country,
      'fees_percentage': instance.feesPercentage,
      'fees_fixed': instance.feesFixed,
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'created_at': instance.createdAt,
    };
