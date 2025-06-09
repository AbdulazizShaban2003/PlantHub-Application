import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class ConditionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const ConditionCard({super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: ColorsManager.whiteColor,
        margin:  EdgeInsets.symmetric(
          vertical: SizeConfig().height(0.01),
          horizontal: SizeConfig().width(0.02),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),

        ),

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 25, color: color),
               SizedBox(width: SizeConfig().width(0.02)),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
