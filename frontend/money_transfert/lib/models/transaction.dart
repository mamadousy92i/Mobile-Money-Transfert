import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final String id;
  final int idTransaction;
  final String codeTransaction;
  final double montantEnvoye;
  final double montantConverti;
  final double montantRecu;
  final String frais;
  final String deviseEnvoi;
  final String deviseReception;
  final String statusTransaction;
  @JsonKey(name: 'status_display')
  final String? statusDisplay;
  final String dateTraitement;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Transaction({
    required this.id,
    required this.idTransaction,
    required this.codeTransaction,
    required this.montantEnvoye,
    required this.montantConverti,
    required this.montantRecu,
    required this.frais,
    required this.deviseEnvoi,
    required this.deviseReception,
    required this.statusTransaction,
    this.statusDisplay,
    required this.dateTraitement,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  // Méthodes utilitaires
  String get statusDisplayText {
    switch (statusTransaction) {
      case 'EN_ATTENTE':
        return 'En Attente';
      case 'ACCEPTE':
        return 'Accepté';
      case 'ENVOYE':
        return 'Envoyé';
      case 'TERMINE':
        return 'Terminé';
      case 'ANNULE':
        return 'Annulé';
      default:
        return statusTransaction;
    }
  }

  bool get isCompleted => statusTransaction == 'TERMINE';
  bool get isPending => statusTransaction == 'EN_ATTENTE';
  bool get isCancelled => statusTransaction == 'ANNULE';
}

// Enum pour les statuts (correspond au Django)
enum TransactionStatus {
  @JsonValue('EN_ATTENTE')
  enAttente,
  @JsonValue('ACCEPTE')
  accepte,
  @JsonValue('ENVOYE')
  envoye,
  @JsonValue('TERMINE')
  termine,
  @JsonValue('ANNULE')
  annule,
}