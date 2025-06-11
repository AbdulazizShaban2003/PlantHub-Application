import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class SetReminderScreen extends StatefulWidget {
  final ActionType actionType;
  final Reminder? existingReminder;

  const SetReminderScreen({
    super.key,
    required this.actionType,
    this.existingReminder,
  });

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  RepeatType _selectedRepeat = RepeatType.daily;
  String _remindMeTo = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      _selectedDateTime = widget.existingReminder!.time;
      _selectedRepeat = widget.existingReminder!.repeat;
      _remindMeTo = widget.existingReminder!.remindMeTo;
    } else {
      _remindMeTo = widget.actionType.displayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Reminder',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Remind me to section
            const Text(
              'Remind me to',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _remindMeTo,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: [widget.actionType.displayName].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _remindMeTo = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Repeat section
            const Text(
              'Repeat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RepeatType>(
                  value: _selectedRepeat,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: RepeatType.values.map((RepeatType repeat) {
                    return DropdownMenuItem<RepeatType>(
                      value: repeat,
                      child: Text(_getRepeatDisplayText(repeat)),
                    );
                  }).toList(),
                  onChanged: (RepeatType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRepeat = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Time section
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_selectedDateTime),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Bottom buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getRepeatDisplayText(RepeatType repeat) {
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveReminder() {
    final reminder = Reminder(
      id: widget.existingReminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: _selectedDateTime,
      repeat: _selectedRepeat,
      remindMeTo: _remindMeTo,
      tasks: [_remindMeTo],
      isActive: true,
    );

    Navigator.pop(context, reminder);
  }
}
