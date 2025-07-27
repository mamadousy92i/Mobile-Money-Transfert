// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionStatusResponse _$TransactionStatusResponseFromJson(
  Map<String, dynamic> json,
) => TransactionStatusResponse(
  code: json['code'] as String,
  status: json['status'] as String,
  statusDisplay: json['status_display'] as String,
  montant: (json['montant'] as num).toDouble(),
  date: json['date'] as String,
);

Map<String, dynamic> _$TransactionStatusResponseToJson(
  TransactionStatusResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': instance.status,
  'status_display': instance.statusDisplay,
  'montant': instance.montant,
  'date': instance.date,
};
