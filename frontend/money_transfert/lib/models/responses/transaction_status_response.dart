import 'package:json_annotation/json_annotation.dart';

part 'transaction_status_response.g.dart';

@JsonSerializable()
class TransactionStatusResponse {
  final String code;
  final String status;
  @JsonKey(name: 'status_display')
  final String statusDisplay;
  final double montant;
  final String date;

  TransactionStatusResponse({
    required this.code,
    required this.status,
    required this.statusDisplay,
    required this.montant,
    required this.date,
  });

  factory TransactionStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionStatusResponseToJson(this);

  bool get isCompleted => status == 'TERMINE';
  bool get isPending => status == 'EN_ATTENTE';
  bool get isCancelled => status == 'ANNULE';
}