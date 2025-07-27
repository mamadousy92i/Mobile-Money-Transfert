// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => TokenPair(
  accessToken: json['access'] as String,
  refreshToken: json['refresh'] as String,
);

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'access': instance.accessToken,
  'refresh': instance.refreshToken,
};
