import 'package:json_annotation/json_annotation.dart';

part 'transaction_stats_response.g.dart';

@JsonSerializable()
class TransactionStatsResponse {
  @JsonKey(name: 'total_transactions')
  final int totalTransactions;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'completed_transactions')
  final int completedTransactions;
  @JsonKey(name: 'pending_transactions')
  final int pendingTransactions;
  @JsonKey(name: 'cancelled_transactions')
  final int cancelledTransactions;
  @JsonKey(name: 'average_amount')
  final String averageAmount;

  TransactionStatsResponse({
    required this.totalTransactions,
    required this.totalAmount,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.cancelledTransactions,
    required this.averageAmount,
  });

  factory TransactionStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionStatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionStatsResponseToJson(this);

  // Méthodes utilitaires
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;
  double get averageAmountAsDouble => double.tryParse(averageAmount) ?? 0.0;

  int get totalActiveTransactions =>
      totalTransactions - cancelledTransactions;

  double get completionRate =>
      totalTransactions > 0 ? completedTransactions / totalTransactions : 0.0;
}