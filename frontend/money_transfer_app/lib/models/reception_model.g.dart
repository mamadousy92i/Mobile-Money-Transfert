// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reception_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reception _$ReceptionFromJson(Map<String, dynamic> json) => Reception(
      id: (json['id'] as num).toInt(),
      expediteurNom: json['expediteur_nom'] as String,
      montantAttendu: double.parse(json['montant_attendu'] as String),
      devise: json['devise'] as String,
      codeReception: json['code_reception'] as String,
      statutReception: json['statut'] as String,
      dateCreation: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReceptionToJson(Reception instance) => <String, dynamic>{
      'id': instance.id,
      'expediteur_nom': instance.expediteurNom,
      'montant_attendu': instance.montantAttendu,
      'devise': instance.devise,
      'code_reception': instance.codeReception,
      'statut': instance.statutReception,
      'created_at': instance.dateCreation.toIso8601String(),
    };
