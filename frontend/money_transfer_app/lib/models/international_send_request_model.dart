// lib/models/international_send_request_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'international_send_request_model.g.dart';

@JsonSerializable()
class InternationalSendRequest {
  @JsonKey(name: 'destinataire_phone')
  final String beneficiaryPhone;
  @JsonKey(name: 'montant')
  final double amount;
  @JsonKey(name: 'pays_destination')
  final String destinationCountryCode;
  @JsonKey(name: 'service_destination')
  final String destinationServiceCode;
  @JsonKey(name: 'canal_paiement_id')
  final String localPaymentChannelId;

  InternationalSendRequest({
    required this.beneficiaryPhone,
    required this.amount,
    required this.destinationCountryCode,
    required this.destinationServiceCode,
    required this.localPaymentChannelId,
  });

  Map<String, dynamic> toJson() => _$InternationalSendRequestToJson(this);
}