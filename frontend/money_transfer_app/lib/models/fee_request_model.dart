// lib/models/fee_request_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'fee_request_model.g.dart';

@JsonSerializable()
class FeeRequest {
  final double montant;
  final String corridor; // Ex: "SEN_TO_COG"
  @JsonKey(name: 'service_destination')
  final String serviceDestination; // Ex: "MTN_MONEY"

  FeeRequest({
    required this.montant,
    required this.corridor,
    required this.serviceDestination,
  });

  Map<String, dynamic> toJson() => _$FeeRequestToJson(this);
}