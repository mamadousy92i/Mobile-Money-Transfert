import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class TokenPair {
  @JsonKey(name: 'access')
  final String accessToken;
  
  @JsonKey(name: 'refresh')
  final String refreshToken;

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) => _$TokenPairFromJson(json);
  
  Map<String, dynamic> toJson() => _$TokenPairToJson(this);
}
