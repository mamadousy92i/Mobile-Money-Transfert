// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      codeTransaction: json['codeTransaction'] as String,
      montantEnvoye: (json['montantEnvoye'] as num).toDouble(),
      montantRecu: (json['montantRecu'] as num).toDouble(),
      frais: json['frais'] as String,
      statusDisplay: json['status_display'] as String,
      typeDisplay: json['type_display'] as String,
      destinataireNom: json['destinataire_nom'] as String,
      expediteurNom: json['expediteur_nom'] as String,
      canalPaiementNom: json['canal_paiement_nom'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      paysOrigine: json['pays_origine'] as String?,
      paysDestination: json['pays_destination'] as String?,
      deviseEnvoi: json['deviseEnvoi'] as String,
      deviseReception: json['deviseReception'] as String,
      statusTransaction: json['statusTransaction'] as String,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codeTransaction': instance.codeTransaction,
      'montantEnvoye': instance.montantEnvoye,
      'montantRecu': instance.montantRecu,
      'frais': instance.frais,
      'status_display': instance.statusDisplay,
      'type_display': instance.typeDisplay,
      'destinataire_nom': instance.destinataireNom,
      'expediteur_nom': instance.expediteurNom,
      'canal_paiement_nom': instance.canalPaiementNom,
      'created_at': instance.createdAt.toIso8601String(),
      'pays_origine': instance.paysOrigine,
      'pays_destination': instance.paysDestination,
      'deviseEnvoi': instance.deviseEnvoi,
      'deviseReception': instance.deviseReception,
      'statusTransaction': instance.statusTransaction,
    };
