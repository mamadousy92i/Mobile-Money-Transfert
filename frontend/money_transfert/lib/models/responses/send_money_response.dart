// lib/models/responses/send_money_response.dart

import 'package:json_annotation/json_annotation.dart';

part 'send_money_response.g.dart';

@JsonSerializable()
class SendMoneyResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  @JsonKey(name: 'code_transaction')
  final String? codeTransaction;
  @JsonKey(name: 'montant_total')
  final double? montantTotal;
  final String? frais;

  SendMoneyResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.codeTransaction,
    this.montantTotal,
    this.frais,
  });

  factory SendMoneyResponse.fromJson(Map<String, dynamic> json) =>
      _$SendMoneyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendMoneyResponseToJson(this);
}

@JsonSerializable()
class SendMoneyRequest {
  @JsonKey(name: 'beneficiaire_phone')
  final String beneficiairePhone;
  final double montant;
  @JsonKey(name: 'canal_paiement')
  final String canalPaiement;
  @JsonKey(name: 'devise_envoi')
  final String? deviseEnvoi;
  @JsonKey(name: 'devise_reception')
  final String? deviseReception;

  SendMoneyRequest({
    required this.beneficiairePhone,
    required this.montant,
    required this.canalPaiement,
    this.deviseEnvoi = 'XOF',
    this.deviseReception = 'XOF',
  });

  factory SendMoneyRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMoneyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendMoneyRequestToJson(this);
}