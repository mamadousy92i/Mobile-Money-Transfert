// lib/models/transaction_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class Transaction {
  final String id;
  @JsonKey(name: 'codeTransaction')
  final String codeTransaction;
  @JsonKey(name: 'montantEnvoye')
  final double montantEnvoye;
  @JsonKey(name: 'montantRecu')
  final double montantRecu;
  final String frais;
  @JsonKey(name: 'status_display')
  final String statusDisplay;
  @JsonKey(name: 'type_display')
  final String typeDisplay;
  @JsonKey(name: 'destinataire_nom')
  final String destinataireNom;
  @JsonKey(name: 'expediteur_nom')
  final String expediteurNom;
  @JsonKey(name: 'canal_paiement_nom')
  final String canalPaiementNom;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'pays_origine')
  final String? paysOrigine;
  @JsonKey(name: 'pays_destination')
  final String? paysDestination;

  // --- AJOUTEZ CES 3 CHAMPS ---
  @JsonKey(name: 'deviseEnvoi')
  final String deviseEnvoi;

  @JsonKey(name: 'deviseReception')
  final String deviseReception;

  @JsonKey(name: 'statusTransaction')
  final String statusTransaction;
  // -----------------------------

  Transaction({
    required this.id,
    required this.codeTransaction,
    required this.montantEnvoye,
    required this.montantRecu,
    required this.frais,
    required this.statusDisplay,
    required this.typeDisplay,
    required this.destinataireNom,
    required this.expediteurNom,
    required this.canalPaiementNom,
    required this.createdAt,
    this.paysOrigine,
    this.paysDestination,
    required this.deviseEnvoi,       // <-- Ajouter au constructeur
    required this.deviseReception,   // <-- Ajouter au constructeur
    required this.statusTransaction, // <-- Ajouter au constructeur
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}