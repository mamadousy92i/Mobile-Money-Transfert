// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agent _$AgentFromJson(Map<String, dynamic> json) => Agent(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      adresse: json['adresse'] as String,
      distance: (json['distance'] as num?)?.toDouble(),
      estOuvert: json['est_ouvert'] as bool,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );

Map<String, dynamic> _$AgentToJson(Agent instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'distance': instance.distance,
      'est_ouvert': instance.estOuvert,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
