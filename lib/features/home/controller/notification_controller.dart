import 'dart:ui';

import 'package:flutter/material.dart';

import '../../my_plant/data/models/notification_model.dart';

Color getActionTypeColor(String actionTypeName) {
  try {
    final actionType = ActionType.values.firstWhere(
          (type) => type.name == actionTypeName,
    );
    return actionType.color;
  } catch (e) {
    return Colors.grey;
  }
}
IconData getActionTypeIcon(String actionTypeName) {
  try {
    final actionType = ActionType.values.firstWhere(
          (type) => type.name == actionTypeName,
    );
    return actionType.icon;
  } catch (e) {
    return Icons.help;
  }
}
String getDateKey(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (notificationDate == today) {
    return 'Today';
  } else if (notificationDate == yesterday) {
    return 'Yesterday';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
String formatTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$displayHour:$minute $period';
}

