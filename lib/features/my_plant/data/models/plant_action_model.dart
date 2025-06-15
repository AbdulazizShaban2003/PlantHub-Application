
import 'notification_model.dart';

class PlantAction {
  final String id;
  final ActionType type;
  final bool isEnabled;
  final Reminder? reminder;

  PlantAction({
    required this.id,
    required this.type,
    required this.isEnabled,
    this.reminder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'isEnabled': isEnabled,
      'reminder': reminder?.toMap(),
    };
  }

  factory PlantAction.fromMap(Map<String, dynamic> map) {
    return PlantAction(
      id: map['id'] ?? '',
      type: ActionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => ActionType.watering,
      ),
      isEnabled: map['isEnabled'] ?? false,
      reminder: map['reminder'] != null ? Reminder.fromMap(map['reminder']) : null,
    );
  }
}
