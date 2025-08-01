// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeResponse _$FeeResponseFromJson(Map<String, dynamic> json) => FeeResponse(
      montantEnvoye: (json['montant_envoye'] as num).toDouble(),
      fraisTotal: (json['frais_total'] as num).toDouble(),
      montantRecu: (json['montant_recu'] as num).toDouble(),
      deviseOrigine: json['devise_origine'] as String,
      deviseDestination: json['devise_destination'] as String,
      tempsEstime: json['temps_estime'] as String,
    );

Map<String, dynamic> _$FeeResponseToJson(FeeResponse instance) =>
    <String, dynamic>{
      'montant_envoye': instance.montantEnvoye,
      'frais_total': instance.fraisTotal,
      'montant_recu': instance.montantRecu,
      'devise_origine': instance.deviseOrigine,
      'devise_destination': instance.deviseDestination,
      'temps_estime': instance.tempsEstime,
    };
