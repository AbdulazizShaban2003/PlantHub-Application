import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';

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
  return Container(
    margin: const EdgeInsets.only(bottom: 25),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color:
            isLogout
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color:
                    isLogout
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
          if (hasToggle)
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeColor: ColorsManager.greenPrimaryColor,
              ),
            ),
          if (!hasToggle && !isLogout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).disabledColor,
              ),
            ),
        ],
      ),
    ),
  );
}