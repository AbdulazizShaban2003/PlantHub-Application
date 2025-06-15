import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/notification_model.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Responsive Icon size
            Icon(Icons.history, size: SizeConfig().responsiveFont(64), color: Colors.grey),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              'No care history yet',
              style: TextStyle(fontSize: SizeConfig().responsiveFont(18), color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      // Responsive padding
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      itemCount: deliveredNotifications.length,
      itemBuilder: (context, index) {
        final notification = deliveredNotifications[index];
        return Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(bottom: SizeConfig().height(0.015)),
          child: ListTile(
            leading: CircleAvatar(
              radius: SizeConfig().width(0.06),
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(
                _getActionTypeIcon(notification.actionType),
                color: ColorsManager.greenPrimaryColor,
                size: SizeConfig().responsiveFont(24),
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(16),
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Completed: ${DateFormatter.formatDateTime(notification.deliveredTime!)}',
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(14),
              ),
            ),
            trailing: Icon( // Removed const
              Icons.check_circle,
              color: ColorsManager.greenPrimaryColor,
              // Responsive Icon size
              size: SizeConfig().responsiveFont(24),
            ),
          ),
        );
      },
    );
  }
}
