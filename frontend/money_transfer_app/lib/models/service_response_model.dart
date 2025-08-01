// lib/models/service_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'payment_service_model.dart';

part 'service_response_model.g.dart';

@JsonSerializable()
class ServiceResponse {
  // On peut ignorer le champ "pays" pour l'instant si on n'en a pas besoin,
  // ou le mapper si nécessaire. Concentrons-nous sur la liste.
  final List<PaymentService> services;

  ServiceResponse({required this.services});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceResponseToJson(this);
}