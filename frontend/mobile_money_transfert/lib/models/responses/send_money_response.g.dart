// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_money_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMoneyResponse _$SendMoneyResponseFromJson(Map<String, dynamic> json) =>
    SendMoneyResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      transactionId: json['transaction_id'] as String?,
      codeTransaction: json['code_transaction'] as String?,
      montantTotal: (json['montant_total'] as num?)?.toDouble(),
      frais: json['frais'] as String?,
    );

Map<String, dynamic> _$SendMoneyResponseToJson(SendMoneyResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'transaction_id': instance.transactionId,
      'code_transaction': instance.codeTransaction,
      'montant_total': instance.montantTotal,
      'frais': instance.frais,
    };

SendMoneyRequest _$SendMoneyRequestFromJson(Map<String, dynamic> json) =>
    SendMoneyRequest(
      beneficiairePhone: json['beneficiaire_phone'] as String,
      montant: (json['montant'] as num).toDouble(),
      canalPaiement: json['canal_paiement'] as String,
      deviseEnvoi: json['devise_envoi'] as String? ?? 'XOF',
      deviseReception: json['devise_reception'] as String? ?? 'XOF',
    );

Map<String, dynamic> _$SendMoneyRequestToJson(SendMoneyRequest instance) =>
    <String, dynamic>{
      'beneficiaire_phone': instance.beneficiairePhone,
      'montant': instance.montant,
      'canal_paiement': instance.canalPaiement,
      'devise_envoi': instance.deviseEnvoi,
      'devise_reception': instance.deviseReception,
    };
