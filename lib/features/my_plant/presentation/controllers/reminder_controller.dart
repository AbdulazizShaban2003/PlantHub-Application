import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino for iOS-style widgets
import '../../data/models/notification_model.dart'; // Assuming this path is correct for your models

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
    DateTime? pickedDate = selectedDateTime; // Initialize with current selected date

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              initialDateTime: selectedDateTime,
              mode: CupertinoDatePickerMode.dateAndTime,
              use24hFormat: false,
              onDateTimeChanged: (DateTime newDateTime) {
                pickedDate = newDateTime;
              },
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      selectedDateTime = pickedDate!;
      return selectedDateTime;
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