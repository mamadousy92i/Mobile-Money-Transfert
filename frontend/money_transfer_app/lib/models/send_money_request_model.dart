// lib/models/send_money_request_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'send_money_request_model.g.dart';

@JsonSerializable()
class SendMoneyRequest {
  @JsonKey(name: 'beneficiaire_phone')
  final String beneficiaryPhone;

  @JsonKey(name: 'montant')
  final double amount;

  @JsonKey(name: 'canal_paiement')
  final String paymentChannelId;

  SendMoneyRequest({
    required this.beneficiaryPhone,
    required this.amount,
    required this.paymentChannelId,
  });

  Map<String, dynamic> toJson() => _$SendMoneyRequestToJson(this);
}