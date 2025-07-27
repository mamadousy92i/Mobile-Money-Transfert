import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'phone_number')
  final String phone;
  
  final String password;

  LoginRequest({
    required this.phone,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  @JsonKey(name: 'phone_number')
  final String phone_number;
  
  final String email;
  final String password;
  
  @JsonKey(name: 'password_confirm')
  final String passwordConfirm;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phone_number,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  
  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone_number,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
      };
}
