// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeRequest _$FeeRequestFromJson(Map<String, dynamic> json) => FeeRequest(
      montant: (json['montant'] as num).toDouble(),
      corridor: json['corridor'] as String,
      serviceDestination: json['service_destination'] as String,
    );

Map<String, dynamic> _$FeeRequestToJson(FeeRequest instance) =>
    <String, dynamic>{
      'montant': instance.montant,
      'corridor': instance.corridor,
      'service_destination': instance.serviceDestination,
    };
