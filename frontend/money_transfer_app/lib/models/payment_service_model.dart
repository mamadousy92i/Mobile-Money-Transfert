// lib/models/payment_service_model.dart
import 'package:json_annotation/json_annotation.dart'; // <-- AJOUTEZ CETTE LIGNE


part 'payment_service_model.g.dart';

@JsonSerializable()
class PaymentService {
  final String code;
  final String nom;
  final String type;
  @JsonKey(name: 'numero_longueur') // <-- AJOUTEZ
  final int? numeroLongueur;

  PaymentService({
    required this.code,
    required this.nom,
    required this.type,
    this.numeroLongueur, // <-- AJOUTEZ
  });

  factory PaymentService.fromJson(Map<String, dynamic> json) =>
      _$PaymentServiceFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentServiceToJson(this);
}