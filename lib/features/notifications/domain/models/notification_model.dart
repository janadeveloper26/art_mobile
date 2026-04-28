import 'package:flutter/material.dart';

enum NotificationType { lesson, promo, review, achievement, live, payment }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String time;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? time,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      read: read ?? this.read,
    );
  }
}
