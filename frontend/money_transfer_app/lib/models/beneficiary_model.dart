// lib/models/beneficiary_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'beneficiary_model.g.dart';

@JsonSerializable()
class Beneficiary {
  final String id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String phone;

  Beneficiary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaryFromJson(json);

  Map<String, dynamic> toJson() => _$BeneficiaryToJson(this);
}