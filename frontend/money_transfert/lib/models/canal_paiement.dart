import 'package:json_annotation/json_annotation.dart';

part 'canal_paiement.g.dart';

@JsonSerializable()
class CanalPaiement {
  final String id;
  @JsonKey(name: 'canal_name')
  final String canalName;
  @JsonKey(name: 'type_canal')
  final String typeCanal;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final String country;
  @JsonKey(name: 'fees_percentage')
  final double feesPercentage;
  @JsonKey(name: 'fees_fixed')
  final double feesFixed;
  @JsonKey(name: 'min_amount')
  final double minAmount;
  @JsonKey(name: 'max_amount')
  final double maxAmount;
  @JsonKey(name: 'created_at')
  final String createdAt;

  CanalPaiement({
    required this.id,
    required this.canalName,
    required this.typeCanal,
    required this.isActive,
    required this.country,
    required this.feesPercentage,
    required this.feesFixed,
    required this.minAmount,
    required this.maxAmount,
    required this.createdAt,
  });

  factory CanalPaiement.fromJson(Map<String, dynamic> json) =>
      _$CanalPaiementFromJson(json);

  Map<String, dynamic> toJson() => _$CanalPaiementToJson(this);

  // Méthodes utilitaires
  double calculateFees(double amount) {
    return (amount * feesPercentage / 100) + feesFixed;
  }

  double calculateTotalAmount(double amount) {
    return amount + calculateFees(amount);
  }

  bool isAmountValid(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  String get displayName {
    switch (typeCanal) {
      case 'WAVE':
        return '📱 Wave';
      case 'ORANGE_MONEY':
        return '🍊 Orange Money';
      case 'KPAY':
        return '💳 K-Pay';
      default:
        return canalName;
    }
  }
}