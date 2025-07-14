import 'package:json_annotation/json_annotation.dart';

part 'exchange_rate_response.g.dart';

// Réponse pour conversion spécifique (?to=EUR)
@JsonSerializable()
class ExchangeRateSpecificResponse {
  final String from;
  final String to;
  final double rate;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  ExchangeRateSpecificResponse({
    required this.from,
    required this.to,
    required this.rate,
    required this.lastUpdated,
  });

  factory ExchangeRateSpecificResponse.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateSpecificResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateSpecificResponseToJson(this);

  double convertAmount(double amount) => amount * rate;
}

// Réponse pour toutes les devises principales
@JsonSerializable()
class ExchangeRateMainResponse {
  @JsonKey(name: 'XOF_TO_EUR')
  final double? xofToEur;
  @JsonKey(name: 'XOF_TO_USD')
  final double? xofToUsd;
  @JsonKey(name: 'XOF_TO_GBP')
  final double? xofToGbp;
  @JsonKey(name: 'XOF_TO_CAD')
  final double? xofToCad;
  @JsonKey(name: 'XOF_TO_MAD')
  final double? xofToMad;
  @JsonKey(name: 'XOF_TO_NGN')
  final double? xofToNgn;
  @JsonKey(name: 'all_currencies')
  final List<String>? allCurrencies;
  @JsonKey(name: 'total_supported')
  final int? totalSupported;
  @JsonKey(name: 'last_updated')
  final String? lastUpdated;

  ExchangeRateMainResponse({
    this.xofToEur,
    this.xofToUsd,
    this.xofToGbp,
    this.xofToCad,
    this.xofToMad,
    this.xofToNgn,
    this.allCurrencies,
    this.totalSupported,
    this.lastUpdated,
  });

  factory ExchangeRateMainResponse.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateMainResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateMainResponseToJson(this);

  // Convertir XOF vers une devise
  double? convertFromXOF(String currency, double amount) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return xofToEur != null ? amount * xofToEur! : null;
      case 'USD':
        return xofToUsd != null ? amount * xofToUsd! : null;
      case 'GBP':
        return xofToGbp != null ? amount * xofToGbp! : null;
      case 'CAD':
        return xofToCad != null ? amount * xofToCad! : null;
      case 'MAD':
        return xofToMad != null ? amount * xofToMad! : null;
      case 'NGN':
        return xofToNgn != null ? amount * xofToNgn! : null;
      default:
        return null;
    }
  }

  List<CurrencyRate> get popularRates => [
    if (xofToEur != null) CurrencyRate('EUR', '🇪🇺', xofToEur!),
    if (xofToUsd != null) CurrencyRate('USD', '🇺🇸', xofToUsd!),
    if (xofToGbp != null) CurrencyRate('GBP', '🇬🇧', xofToGbp!),
    if (xofToMad != null) CurrencyRate('MAD', '🇲🇦', xofToMad!),
    if (xofToNgn != null) CurrencyRate('NGN', '🇳🇬', xofToNgn!),
  ];
}

// Classe utilitaire pour afficher les taux
class CurrencyRate {
  final String code;
  final String flag;
  final double rate;

  CurrencyRate(this.code, this.flag, this.rate);

  String get displayName => '$flag $code';
}