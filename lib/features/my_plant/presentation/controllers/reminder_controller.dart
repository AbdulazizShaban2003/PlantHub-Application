// controllers/reminder_controller.dart
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class ReminderController {
  DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  RepeatType selectedRepeat = RepeatType.daily;
  String remindMeTo = '';

  void initialize(ActionType actionType, Reminder? existingReminder) {
    if (existingReminder != null) {
      selectedDateTime = existingReminder.time;
      selectedRepeat = existingReminder.repeat;
      remindMeTo = existingReminder.remindMeTo;
    } else {
      remindMeTo = actionType.displayName;
    }
  }

  String getRepeatDisplayText(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.once:
        return 'Once';
      case RepeatType.daily:
        return 'Every day';
      case RepeatType.weekly:
        return 'Every week';
      case RepeatType.monthly:
        return 'Every month';
    }
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<DateTime?> selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (time != null) {
        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        return selectedDateTime;
      }
    }
    return null;
  }

  Reminder saveReminder() {
    return Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: selectedDateTime,
      repeat: selectedRepeat,
      remindMeTo: remindMeTo,
      tasks: [remindMeTo],
      isActive: true,
    );
  }
}