// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_calculation_wrapper_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeCalculationWrapper _$FeeCalculationWrapperFromJson(
        Map<String, dynamic> json) =>
    FeeCalculationWrapper(
      success: json['success'] as bool,
      calculs: FeeResponse.fromJson(json['calculs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeeCalculationWrapperToJson(
        FeeCalculationWrapper instance) =>
    <String, dynamic>{
      'success': instance.success,
      'calculs': instance.calculs,
    };
