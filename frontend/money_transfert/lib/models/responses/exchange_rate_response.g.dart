// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeRateSpecificResponse _$ExchangeRateSpecificResponseFromJson(
  Map<String, dynamic> json,
) => ExchangeRateSpecificResponse(
  from: json['from'] as String,
  to: json['to'] as String,
  rate: (json['rate'] as num).toDouble(),
  lastUpdated: json['last_updated'] as String,
);

Map<String, dynamic> _$ExchangeRateSpecificResponseToJson(
  ExchangeRateSpecificResponse instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'rate': instance.rate,
  'last_updated': instance.lastUpdated,
};

ExchangeRateMainResponse _$ExchangeRateMainResponseFromJson(
  Map<String, dynamic> json,
) => ExchangeRateMainResponse(
  xofToEur: (json['XOF_TO_EUR'] as num?)?.toDouble(),
  xofToUsd: (json['XOF_TO_USD'] as num?)?.toDouble(),
  xofToGbp: (json['XOF_TO_GBP'] as num?)?.toDouble(),
  xofToCad: (json['XOF_TO_CAD'] as num?)?.toDouble(),
  xofToMad: (json['XOF_TO_MAD'] as num?)?.toDouble(),
  xofToNgn: (json['XOF_TO_NGN'] as num?)?.toDouble(),
  allCurrencies:
      (json['all_currencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  totalSupported: (json['total_supported'] as num?)?.toInt(),
  lastUpdated: json['last_updated'] as String?,
);

Map<String, dynamic> _$ExchangeRateMainResponseToJson(
  ExchangeRateMainResponse instance,
) => <String, dynamic>{
  'XOF_TO_EUR': instance.xofToEur,
  'XOF_TO_USD': instance.xofToUsd,
  'XOF_TO_GBP': instance.xofToGbp,
  'XOF_TO_CAD': instance.xofToCad,
  'XOF_TO_MAD': instance.xofToMad,
  'XOF_TO_NGN': instance.xofToNgn,
  'all_currencies': instance.allCurrencies,
  'total_supported': instance.totalSupported,
  'last_updated': instance.lastUpdated,
};
