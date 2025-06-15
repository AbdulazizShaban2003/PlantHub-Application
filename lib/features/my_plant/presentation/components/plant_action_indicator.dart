import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/my_plant/data/models/notification_model.dart';
import 'package:plant_hub_app/core/utils/size_config.dart'; // Import SizeConfig

class PlantActionIndicator extends StatelessWidget {
  final PlantAction action;

  const PlantActionIndicator({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig().width(0.03),
        vertical: SizeConfig().height(0.0075),
      ),
      decoration: BoxDecoration(
        color: action.type.color.withOpacity(0.1),
        // Responsive border radius
        borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
        border: Border.all(color: action.type.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            action.type.icon,
            // Responsive icon size
            size: SizeConfig().responsiveFont(16),
            color: action.type.color,
          ),
          SizedBox(width: SizeConfig().width(0.01)),
          Text(
            action.type.displayName,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(12),
              color: action.type.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
