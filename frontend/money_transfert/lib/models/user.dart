import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  @JsonKey(name: 'phone_number')
  final String phone;
  
  final String email;
  
  @JsonKey(name: 'kyc_status')
  final String kycStatus;
  
  @JsonKey(name: 'verification_level', defaultValue: 'non vérifié')
  final String verificationLevel;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isAuthenticated;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool? isNewUser;
  
  @JsonKey(name: 'date_joined')
  final String memberSince;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.kycStatus,
    required this.verificationLevel,
    this.isAuthenticated = true,
    this.isNewUser,
    required this.memberSince,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName';
}
