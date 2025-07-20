// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiErrorResponse _$ApiErrorResponseFromJson(Map<String, dynamic> json) =>
    ApiErrorResponse(
      error: json['error'] as String?,
      message: json['message'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiErrorResponseToJson(ApiErrorResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'details': instance.details,
      'errors': instance.errors,
    };
