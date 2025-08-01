// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      phoneNumber: json['phone_number'] as String,
      password: json['password'] as String,
      passwordConfirm: json['password_confirm'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'password': instance.password,
      'password_confirm': instance.passwordConfirm,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'error': instance.error,
    };
