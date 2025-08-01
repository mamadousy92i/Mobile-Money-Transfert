// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_channel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentChannel _$PaymentChannelFromJson(Map<String, dynamic> json) =>
    PaymentChannel(
      id: json['id'] as String,
      canalName: json['canal_name'] as String,
      typeCanal: json['type_canal'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$PaymentChannelToJson(PaymentChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'canal_name': instance.canalName,
      'type_canal': instance.typeCanal,
      'is_active': instance.isActive,
    };
