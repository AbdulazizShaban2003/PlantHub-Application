import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/notification_model.dart';

class HistoryTab extends StatelessWidget {
  final List<NotificationModel> plantNotifications;

  const HistoryTab({super.key, required this.plantNotifications});

  IconData _getActionTypeIcon(String actionTypeName) {
    try {
      final actionType = ActionType.values.firstWhere(
            (type) => type.name == actionTypeName,
      );
      return actionType.icon;
    } catch (e) {
      return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveredNotifications = plantNotifications
        .where((notification) => notification.isDelivered)
        .toList()
      ..sort((a, b) => b.deliveredTime!.compareTo(a.deliveredTime!));

    if (deliveredNotifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No care history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveredNotifications.length,
      itemBuilder: (context, index) {
        final notification = deliveredNotifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(
                _getActionTypeIcon(notification.actionType),
                color: Colors.green,
              ),
            ),
            title: Text(notification.title),
            subtitle: Text(
              'Completed: ${DateFormatter.formatDateTime(notification.deliveredTime!)}',
            ),
            trailing: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }
}