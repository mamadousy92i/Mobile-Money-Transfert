// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionStatsResponse _$TransactionStatsResponseFromJson(
  Map<String, dynamic> json,
) => TransactionStatsResponse(
  totalTransactions: (json['total_transactions'] as num).toInt(),
  totalAmount: json['total_amount'] as String,
  completedTransactions: (json['completed_transactions'] as num).toInt(),
  pendingTransactions: (json['pending_transactions'] as num).toInt(),
  cancelledTransactions: (json['cancelled_transactions'] as num).toInt(),
  averageAmount: json['average_amount'] as String,
);

Map<String, dynamic> _$TransactionStatsResponseToJson(
  TransactionStatsResponse instance,
) => <String, dynamic>{
  'total_transactions': instance.totalTransactions,
  'total_amount': instance.totalAmount,
  'completed_transactions': instance.completedTransactions,
  'pending_transactions': instance.pendingTransactions,
  'cancelled_transactions': instance.cancelledTransactions,
  'average_amount': instance.averageAmount,
};
