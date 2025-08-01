// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_money_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMoneyRequest _$SendMoneyRequestFromJson(Map<String, dynamic> json) =>
    SendMoneyRequest(
      beneficiaryPhone: json['beneficiaire_phone'] as String,
      amount: (json['montant'] as num).toDouble(),
      paymentChannelId: json['canal_paiement'] as String,
    );

Map<String, dynamic> _$SendMoneyRequestToJson(SendMoneyRequest instance) =>
    <String, dynamic>{
      'beneficiaire_phone': instance.beneficiaryPhone,
      'montant': instance.amount,
      'canal_paiement': instance.paymentChannelId,
    };
