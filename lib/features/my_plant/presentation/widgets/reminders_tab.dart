import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/size_config.dart';
import '../../models/notification_model.dart';

class RemindersTab extends StatelessWidget {
  final List<NotificationModel> plantNotifications;

  const RemindersTab({super.key, required this.plantNotifications});

  Color _getActionTypeColor(String actionTypeName) {
    try {
      final actionType = ActionType.values.firstWhere(
            (type) => type.name == actionTypeName,
      );
      return actionType.color;
    } catch (e) {
      return ColorsManager.greyColor;
    }
  }

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
    SizeConfig().init(context);

    if (plantNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: SizeConfig().responsiveFont(64), color: ColorsManager.greyColor),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              AppStrings.noRemindersYet,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(18), color: ColorsManager.greyColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      itemCount: plantNotifications.length,
      itemBuilder: (context, index) {
        final notification = plantNotifications[index];
        return Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(bottom: SizeConfig().height(0.015)),
          child: ListTile(
            leading: CircleAvatar(
              radius: SizeConfig().responsiveFont(24),
              backgroundColor: _getActionTypeColor(notification.actionType).withOpacity(0.1),
              child: Icon(
                _getActionTypeIcon(notification.actionType),
                color: _getActionTypeColor(notification.actionType),
                size: SizeConfig().responsiveFont(24),
              ),
            ),
            title: Text(
              notification.title,
              style: Theme.of(context).textTheme.bodySmall
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${AppStrings.scheduled} ${DateFormatter.formatDateTime(notification.scheduledTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  notification.isDelivered ? Icons.check_circle : Icons.schedule,
                  color: notification.isDelivered ? ColorsManager.greenPrimaryColor : ColorsManager.orangeAccentColor,
                  size: SizeConfig().responsiveFont(24),
                ),
                Text(
                  notification.isDelivered ? AppStrings.sent : AppStrings.pending,
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(10),
                    color: notification.isDelivered ? ColorsManager.greenPrimaryColor : ColorsManager.orangeAccentColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
