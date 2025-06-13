import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/my_plant/models/notification_model.dart';

class PlantActionIndicator extends StatelessWidget {
  final PlantAction action;

  const PlantActionIndicator({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: action.type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: action.type.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            action.type.icon,
            size: 16,
            color: action.type.color,
          ),
          const SizedBox(width: 4),
          Text(
            action.type.displayName,
            style: TextStyle(
              fontSize: 12,
              color: action.type.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}