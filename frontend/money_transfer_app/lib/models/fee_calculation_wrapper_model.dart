// lib/models/fee_calculation_wrapper_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'fee_response_model.dart';

part 'fee_calculation_wrapper_model.g.dart';

@JsonSerializable()
class FeeCalculationWrapper {
  final bool success;
  final FeeResponse calculs;

  FeeCalculationWrapper({required this.success, required this.calculs});

  factory FeeCalculationWrapper.fromJson(Map<String, dynamic> json) =>
      _$FeeCalculationWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$FeeCalculationWrapperToJson(this);
}