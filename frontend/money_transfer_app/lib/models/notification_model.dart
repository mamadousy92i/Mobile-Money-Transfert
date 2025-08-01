// lib/models/notification_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String title;
  final String message;
  @JsonKey(name: 'notification_type')
  final String notificationType;
  @JsonKey(name: 'status')
  final String readStatus;
  bool get isUnread => readStatus == 'UNREAD';


  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.readStatus,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}