// lib/models/reception_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'reception_model.g.dart';

@JsonSerializable()
class Reception {
  final int id;
  @JsonKey(name: 'expediteur_nom')
  final String expediteurNom;
  @JsonKey(name: 'montant_attendu', fromJson: double.parse)
  final double montantAttendu;
  @JsonKey(name: 'devise')
  final String devise;
  @JsonKey(name: 'code_reception')
  final String codeReception;
  @JsonKey(name: 'statut')
  final String statutReception;
  @JsonKey(name: 'created_at')
  final DateTime dateCreation;

  Reception({
    required this.id,
    required this.expediteurNom,
    required this.montantAttendu,
    required this.devise,
    required this.codeReception,
    required this.statutReception,
    required this.dateCreation,
  });

  factory Reception.fromJson(Map<String, dynamic> json) =>
      _$ReceptionFromJson(json);
}