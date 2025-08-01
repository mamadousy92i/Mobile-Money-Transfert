// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalResponse _$WithdrawalResponseFromJson(Map<String, dynamic> json) =>
    WithdrawalResponse(
      id: (json['id'] as num).toInt(),
      withdrawalCode: json['code_retrait'] as String,
      qrCodeUrl: json['qr_code'] as String,
      statut: json['statut'] as String,
      montantRetire: json['montant_retire'] as String?,
      commissionAgent: json['commission_agent'] as String?,
      statutFormatted: json['statut_formatted'] as String?,
      dateDemande: json['date_demande'] as String?,
      dateRetrait: json['date_retrait'] as String?,
      pieceIdentiteVerifie: json['piece_identite_verifie'] as bool?,
      notesVerification: json['notes_verification'] as String?,
      agentInfo: json['agent_info'] == null
          ? null
          : AgentInfo.fromJson(json['agent_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WithdrawalResponseToJson(WithdrawalResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code_retrait': instance.withdrawalCode,
      'qr_code': instance.qrCodeUrl,
      'statut': instance.statut,
      'montant_retire': instance.montantRetire,
      'commission_agent': instance.commissionAgent,
      'statut_formatted': instance.statutFormatted,
      'date_demande': instance.dateDemande,
      'date_retrait': instance.dateRetrait,
      'piece_identite_verifie': instance.pieceIdentiteVerifie,
      'notes_verification': instance.notesVerification,
      'agent_info': instance.agentInfo,
    };

AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) => AgentInfo(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      email: json['email'] as String,
      adresse: json['adresse'] as String,
      statutAgent: json['statut_agent'] as String,
      soldeCompte: json['solde_compte'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      heureOuverture: json['heure_ouverture'] as String,
      heureFermeture: json['heure_fermeture'] as String,
      limiteRetraitJournalier: json['limite_retrait_journalier'] as String,
      commissionPourcentage: json['commission_pourcentage'] as String,
      distance: json['distance'] as String?,
      estOuvert: json['est_ouvert'] as bool,
      estDisponible: json['est_disponible'] as bool,
      nomComplet: json['nom_complet'] as String,
      dateCreation: json['date_creation'] as String,
    );

Map<String, dynamic> _$AgentInfoToJson(AgentInfo instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'email': instance.email,
      'adresse': instance.adresse,
      'statut_agent': instance.statutAgent,
      'solde_compte': instance.soldeCompte,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heure_ouverture': instance.heureOuverture,
      'heure_fermeture': instance.heureFermeture,
      'limite_retrait_journalier': instance.limiteRetraitJournalier,
      'commission_pourcentage': instance.commissionPourcentage,
      'distance': instance.distance,
      'est_ouvert': instance.estOuvert,
      'est_disponible': instance.estDisponible,
      'nom_complet': instance.nomComplet,
      'date_creation': instance.dateCreation,
    };
