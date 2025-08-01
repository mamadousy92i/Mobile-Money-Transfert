// lib/models/payment_channel_model.dart
import 'package:json_annotation/json_annotation.dart';

// La ligne manquante à ajouter
part 'payment_channel_model.g.dart';

@JsonSerializable()
class PaymentChannel {
  final String id;
  @JsonKey(name: 'canal_name')
  final String canalName;
  @JsonKey(name: 'type_canal')
  final String typeCanal;
  @JsonKey(name: 'is_active')
  final bool isActive;

  PaymentChannel({
    required this.id,
    required this.canalName,
    required this.typeCanal,
    required this.isActive,
  });

  factory PaymentChannel.fromJson(Map<String, dynamic> json) =>
      _$PaymentChannelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentChannelToJson(this);
}