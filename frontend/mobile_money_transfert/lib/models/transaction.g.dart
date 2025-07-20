// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  idTransaction: (json['idTransaction'] as num).toInt(),
  codeTransaction: json['codeTransaction'] as String,
  montantEnvoye: (json['montantEnvoye'] as num).toDouble(),
  montantConverti: (json['montantConverti'] as num).toDouble(),
  montantRecu: (json['montantRecu'] as num).toDouble(),
  frais: json['frais'] as String,
  deviseEnvoi: json['deviseEnvoi'] as String,
  deviseReception: json['deviseReception'] as String,
  statusTransaction: json['statusTransaction'] as String,
  statusDisplay: json['status_display'] as String?,
  dateTraitement: json['dateTraitement'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idTransaction': instance.idTransaction,
      'codeTransaction': instance.codeTransaction,
      'montantEnvoye': instance.montantEnvoye,
      'montantConverti': instance.montantConverti,
      'montantRecu': instance.montantRecu,
      'frais': instance.frais,
      'deviseEnvoi': instance.deviseEnvoi,
      'deviseReception': instance.deviseReception,
      'statusTransaction': instance.statusTransaction,
      'status_display': instance.statusDisplay,
      'dateTraitement': instance.dateTraitement,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
