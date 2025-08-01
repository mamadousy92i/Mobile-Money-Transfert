// lib/models/withdrawal_request_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_request_model.g.dart';

@JsonSerializable()
class WithdrawalRequest {
  @JsonKey(name: 'agent_id')
  final int agentId;
  @JsonKey(name: 'montant_retire')
  final double amount;

  WithdrawalRequest({required this.agentId, required this.amount});

  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);
}