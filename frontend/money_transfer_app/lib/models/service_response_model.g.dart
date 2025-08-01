// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceResponse _$ServiceResponseFromJson(Map<String, dynamic> json) =>
    ServiceResponse(
      services: (json['services'] as List<dynamic>)
          .map((e) => PaymentService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ServiceResponseToJson(ServiceResponse instance) =>
    <String, dynamic>{
      'services': instance.services,
    };
