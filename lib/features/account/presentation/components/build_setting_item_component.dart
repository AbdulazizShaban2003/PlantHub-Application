import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

Widget buildSettingItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required bool hasToggle,
  String? subtitle,
  bool toggleValue = false,
  bool isLogout = false,
  Function(bool)? onToggleChanged,
  VoidCallback? onTap,
}) {
  SizeConfig().init(context);

  return Container(
    margin: EdgeInsets.only(bottom: SizeConfig().height(0.03)),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: SizeConfig().responsiveFont(24),
            color: isLogout
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          SizedBox(width: SizeConfig().width(0.05)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(16),
                    fontWeight: FontWeight.w400,
                    color: isLogout
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: SizeConfig().responsiveFont(14),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
          if (hasToggle)
            Transform.scale(
              scale: SizeConfig().width(0.002),
              child: Switch(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeColor: ColorsManager.greenPrimaryColor,
              ),
            ),
          if (!hasToggle && !isLogout)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.05)),
              child: Icon(
                Icons.arrow_forward_ios,
                size: SizeConfig().responsiveFont(16),
                color: Theme.of(context).disabledColor,
              ),
            ),
        ],
      ),
    ),
  );
}