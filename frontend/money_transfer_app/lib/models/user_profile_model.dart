// lib/models/user_profile_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'kyc_status')
  final String kycStatus;
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.kycStatus,
    required this.dateJoined,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  String get fullName => '$firstName $lastName';
}