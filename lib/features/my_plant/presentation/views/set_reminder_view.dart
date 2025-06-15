// views/set_reminder_view.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../../data/models/notification_model.dart';
import '../components/custom_dropdown.dart';
import '../components/custom_time_picker.dart';
import '../controllers/reminder_controller.dart';
import 'package:plant_hub_app/core/utils/size_config.dart'; // Import SizeConfig

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
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set Reminder',
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeConfig().responsiveFont(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.06)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig().height(0.025)),

            CustomDropdown(
              title: 'Remind me to',
              value: _controller.remindMeTo,
              items: [widget.actionType.displayName],
              onChanged:
                  (value) => setState(() => _controller.remindMeTo = value!),
            ),

            SizedBox(height: SizeConfig().height(0.04)),
            CustomDropdown<RepeatType>(
              title: 'Repeat',
              value: _controller.selectedRepeat,
              items: RepeatType.values,
              displayText: _controller.getRepeatDisplayText,
              onChanged:
                  (value) =>
                  setState(() => _controller.selectedRepeat = value!),
            ),

            SizedBox(height: SizeConfig().height(0.04)),

            CustomTimePicker(
              title: 'Time',
              selectedDateTime: _controller.selectedDateTime,
              onTap: () async {
                final dateTime = await _controller.selectDateTime(context);
                if (dateTime != null) setState(() {});
              },
            ),

            Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButtonWidget(
                    nameButton: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: SizeConfig().width(0.04)),
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
            SizedBox(height: SizeConfig().height(0.04)),
          ],
        ),
      ),
    );
  }
}
