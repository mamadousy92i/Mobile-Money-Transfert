import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginUser {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'password')
  final String password;

  LoginUser({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}