// views/set_reminder_view.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../../models/notification_model.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_time_picker.dart';
import '../controllers/reminder_controller.dart';

class SetReminderView extends StatefulWidget {
  final ActionType actionType;
  final Reminder? existingReminder;

  const SetReminderView({
    super.key,
    required this.actionType,
    this.existingReminder,
  });

  @override
  State<SetReminderView> createState() => _SetReminderViewState();
}

class _SetReminderViewState extends State<SetReminderView> {
  final ReminderController _controller = ReminderController();

  @override
  void initState() {
    super.initState();
    _controller.initialize(widget.actionType, widget.existingReminder);
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

            CustomDropdown(
              title: 'Remind me to',
              value: _controller.remindMeTo,
              items: [widget.actionType.displayName],
              onChanged: (value) => setState(() => _controller.remindMeTo = value!),
            ),

            const SizedBox(height: 32),

            CustomDropdown<RepeatType>(
              title: 'Repeat',
              value: _controller.selectedRepeat,
              items: RepeatType.values,
              displayText: _controller.getRepeatDisplayText,
              onChanged: (value) => setState(() => _controller.selectedRepeat = value!),
            ),

            const SizedBox(height: 32),

            CustomTimePicker(
              title: 'Time',
              selectedDateTime: _controller.selectedDateTime,
              onTap: () async {
                final dateTime = await _controller.selectDateTime(context);
                if (dateTime != null) setState(() {});
              },
            ),

            const Spacer(),

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
                  child: OutlinedButtonWidget(
                    nameButton: 'Save',
                    onPressed: () {
                      final reminder = _controller.saveReminder();
                      Navigator.pop(context, reminder);
                    },
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
}