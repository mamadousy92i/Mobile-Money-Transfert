import 'package:json_annotation/json_annotation.dart';

part 'api_error_response.g.dart';

@JsonSerializable()
class ApiErrorResponse {
  final String? error;
  final String? message;
  final Map<String, dynamic>? details;
  final Map<String, dynamic>? errors;

  ApiErrorResponse({
    this.error,
    this.message,
    this.details,
    this.errors,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);

  String get displayMessage {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    if (error != null && error!.isNotEmpty) {
      return error!;
    }
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.toString();
    }
    return 'Une erreur inconnue s\'est produite';
  }

  List<String> get validationErrors {
    if (errors == null) return [];

    List<String> errorList = [];
    errors!.forEach((field, messages) {
      if (messages is List) {
        errorList.addAll(messages.map((e) => e.toString()));
      } else {
        errorList.add(messages.toString());
      }
    });
    return errorList;
  }
}