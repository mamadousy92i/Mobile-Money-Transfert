import 'package:json_annotation/json_annotation.dart';

part 'beneficiaire.g.dart';

@JsonSerializable()
class Beneficiaire {
  final String id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String phone;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Beneficiaire({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Beneficiaire.fromJson(Map<String, dynamic> json) =>
      _$BeneficiaireFromJson(json);

  Map<String, dynamic> toJson() => _$BeneficiaireToJson(this);

  // Méthodes utilitaires
  String get fullName => '$firstName $lastName';

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return fullName;
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else {
      return phone;
    }
  }

  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return firstInitial + lastInitial;
  }
}