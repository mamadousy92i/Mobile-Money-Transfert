// lib/models/withdrawal_response_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_response_model.g.dart';

@JsonSerializable()
class WithdrawalResponse {
  final int id;
  @JsonKey(name: 'code_retrait')
  final String withdrawalCode;
  @JsonKey(name: 'qr_code')
  final String qrCodeUrl;
  final String statut;
  @JsonKey(name: 'montant_retire')
  final String? montantRetire; // String car l'API retourne une chaîne
  @JsonKey(name: 'commission_agent')
  final String? commissionAgent; // String car l'API retourne une chaîne
  @JsonKey(name: 'statut_formatted')
  final String? statutFormatted;
  @JsonKey(name: 'date_demande')
  final String? dateDemande;
  @JsonKey(name: 'date_retrait')
  final String? dateRetrait;
  @JsonKey(name: 'piece_identite_verifie')
  final bool? pieceIdentiteVerifie;
  @JsonKey(name: 'notes_verification')
  final String? notesVerification;
  @JsonKey(name: 'agent_info')
  final AgentInfo? agentInfo;

  WithdrawalResponse({
    required this.id,
    required this.withdrawalCode,
    required this.qrCodeUrl,
    required this.statut,
    this.montantRetire,
    this.commissionAgent,
    this.statutFormatted,
    this.dateDemande,
    this.dateRetrait,
    this.pieceIdentiteVerifie,
    this.notesVerification,
    this.agentInfo,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalResponseFromJson(json);
}

@JsonSerializable()
class AgentInfo {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String email;
  final String adresse;
  @JsonKey(name: 'statut_agent')
  final String statutAgent;
  @JsonKey(name: 'solde_compte')
  final String soldeCompte;
  final String latitude;
  final String longitude;
  @JsonKey(name: 'heure_ouverture')
  final String heureOuverture;
  @JsonKey(name: 'heure_fermeture')
  final String heureFermeture;
  @JsonKey(name: 'limite_retrait_journalier')
  final String limiteRetraitJournalier;
  @JsonKey(name: 'commission_pourcentage')
  final String commissionPourcentage;
  final String? distance;
  @JsonKey(name: 'est_ouvert')
  final bool estOuvert;
  @JsonKey(name: 'est_disponible')
  final bool estDisponible;
  @JsonKey(name: 'nom_complet')
  final String nomComplet;
  @JsonKey(name: 'date_creation')
  final String dateCreation;

  AgentInfo({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.adresse,
    required this.statutAgent,
    required this.soldeCompte,
    required this.latitude,
    required this.longitude,
    required this.heureOuverture,
    required this.heureFermeture,
    required this.limiteRetraitJournalier,
    required this.commissionPourcentage,
    this.distance,
    required this.estOuvert,
    required this.estDisponible,
    required this.nomComplet,
    required this.dateCreation,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) =>
      _$AgentInfoFromJson(json);
}