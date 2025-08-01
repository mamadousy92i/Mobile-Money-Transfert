// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentService _$PaymentServiceFromJson(Map<String, dynamic> json) =>
    PaymentService(
      code: json['code'] as String,
      nom: json['nom'] as String,
      type: json['type'] as String,
      numeroLongueur: (json['numero_longueur'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaymentServiceToJson(PaymentService instance) =>
    <String, dynamic>{
      'code': instance.code,
      'nom': instance.nom,
      'type': instance.type,
      'numero_longueur': instance.numeroLongueur,
    };
