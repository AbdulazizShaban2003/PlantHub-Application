import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/size_config.dart';
import '../../data/models/notification_model.dart';
class CareScheduleTab extends StatelessWidget {
  final Plant plant;

  const CareScheduleTab({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final enabledActions = plant.actions.where((action) => action.isEnabled).toList();

    if (enabledActions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: SizeConfig().responsiveFont(64), color: ColorsManager.greyColor),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              AppStrings.noCareScheduleSet,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(18), color: ColorsManager.greyColor),
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            Text(
              AppStrings.editPlantToAddReminders,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(14), color: ColorsManager.greyColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      itemCount: enabledActions.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final action = enabledActions[index];
        return Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(bottom: SizeConfig().height(0.015)),
          child: ListTile(
            leading: Container(
              width: SizeConfig().width(0.12),
              height: SizeConfig().width(0.12),
              decoration: BoxDecoration(
                color: action.type.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.type.icon,
                color: action.type.color,
                size: SizeConfig().responsiveFont(24),
              ),
            ),
            title: Text(
              action.type.displayName,
              style: Theme.of(context).textTheme.bodyMedium
            ),
            subtitle: action.reminder != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.next} ${DateFormatter.formatDateTime(action.reminder!.time)}',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                ),
                Text(
                  '${AppStrings.repeat} ${action.reminder!.repeat.displayName}',
                  style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                ),
                if (action.reminder!.tasks.isNotEmpty)
                  Text(
                    '${AppStrings.tasks} ${action.reminder!.tasks.join(', ')}',
                    style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
                  ),
              ],
            )
                : Text(
              AppStrings.noReminderSet,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
            ),
            trailing: action.reminder != null
                ? Icon(Icons.notifications_active, color: action.type.color, size: SizeConfig().responsiveFont(24))
                : Icon(Icons.notifications_off, color: ColorsManager.greyColor, size: SizeConfig().responsiveFont(24)),
          ),
        );
      },
    );
  }
}
