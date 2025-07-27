// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone_number'] as String,
  email: json['email'] as String,
  kycStatus: json['kyc_status'] as String,
  verificationLevel: json['verification_level'] as String? ?? 'non vérifié',
  memberSince: json['date_joined'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone_number': instance.phone,
  'email': instance.email,
  'kyc_status': instance.kycStatus,
  'verification_level': instance.verificationLevel,
  'date_joined': instance.memberSince,
};
