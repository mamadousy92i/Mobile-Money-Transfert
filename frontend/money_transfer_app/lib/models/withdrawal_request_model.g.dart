// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    WithdrawalRequest(
      agentId: (json['agent_id'] as num).toInt(),
      amount: (json['montant_retire'] as num).toDouble(),
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'agent_id': instance.agentId,
      'montant_retire': instance.amount,
    };
