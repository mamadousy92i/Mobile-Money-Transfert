// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'international_send_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InternationalSendRequest _$InternationalSendRequestFromJson(
        Map<String, dynamic> json) =>
    InternationalSendRequest(
      beneficiaryPhone: json['destinataire_phone'] as String,
      amount: (json['montant'] as num).toDouble(),
      destinationCountryCode: json['pays_destination'] as String,
      destinationServiceCode: json['service_destination'] as String,
      localPaymentChannelId: json['canal_paiement_id'] as String,
    );

Map<String, dynamic> _$InternationalSendRequestToJson(
        InternationalSendRequest instance) =>
    <String, dynamic>{
      'destinataire_phone': instance.beneficiaryPhone,
      'montant': instance.amount,
      'pays_destination': instance.destinationCountryCode,
      'service_destination': instance.destinationServiceCode,
      'canal_paiement_id': instance.localPaymentChannelId,
    };
