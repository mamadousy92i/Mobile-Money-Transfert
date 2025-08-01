import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'password')
  final String password;
  @JsonKey(name: 'password_confirm')
  final String passwordConfirm;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'email')
  final String email;


  User({
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirm,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String? access;
  final String? refresh;
  final String? error;

  AuthResponse({this.access, this.refresh, this.error});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}