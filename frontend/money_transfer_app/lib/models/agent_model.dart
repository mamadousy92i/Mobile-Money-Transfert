// lib/models/agent_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'agent_model.g.dart';

@JsonSerializable()
class Agent {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String adresse;
  final double? distance;
  @JsonKey(name: 'est_ouvert')
  final bool estOuvert;
  // Assurez-vous que ces deux champs sont bien présents
  final String? latitude;  // <-- MODIFIÉ : de double? à String?
  final String? longitude;

  Agent({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    this.distance,
    required this.estOuvert,
    this.latitude,
    this.longitude,
  });

  String get nomComplet => '$prenom $nom';

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
  Map<String, dynamic> toJson() => _$AgentToJson(this);
}