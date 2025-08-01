// lib/models/fee_response_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'fee_response_model.g.dart';

@JsonSerializable()
class FeeResponse {
  @JsonKey(name: 'montant_envoye')
  final double montantEnvoye;
  @JsonKey(name: 'frais_total')
  final double fraisTotal;
  @JsonKey(name: 'montant_recu')
  final double montantRecu;
  @JsonKey(name: 'devise_origine')
  final String deviseOrigine;
  @JsonKey(name: 'devise_destination')
  final String deviseDestination;
  @JsonKey(name: 'temps_estime')
  final String tempsEstime;

  FeeResponse({
    required this.montantEnvoye,
    required this.fraisTotal,
    required this.montantRecu,
    required this.deviseOrigine,
    required this.deviseDestination,
    required this.tempsEstime,
  });

  factory FeeResponse.fromJson(Map<String, dynamic> json) =>
      _$FeeResponseFromJson(json);
}