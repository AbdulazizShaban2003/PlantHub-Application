import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../data/models/climatic_condition_model.dart';
import '../sections/custom_condition_section.dart';

class ConditionsTab extends StatelessWidget {
  final ClimaticConditions? conditions;

  const ConditionsTab({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    if (conditions == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thermostat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No climate conditions information available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ConditionCard(
          icon: Icons.thermostat,
          title: AppKeyStringTr.temperature,
          value: conditions!.temperature ?? 'Not specified',
          color: ColorsManager.redColor,
        ),
        ConditionCard(
          icon: Icons.grass,
          title: AppKeyStringTr.soil,
          value: conditions!.soil ?? 'Not specified',
          color: ColorsManager.brownColor,
        ),
        ConditionCard(
          icon: Icons.water_drop,
          title: AppKeyStringTr.moisture,
          value: conditions!.moisture ?? 'Not specified',
          color: ColorsManager.lightBlueColor,
        ),
        ConditionCard(
          icon: Icons.warning,
          title: AppKeyStringTr.sensitivity,
          value: conditions!.sensitivity ?? 'Not specified',
          color: ColorsManager.yellowColor,
        ),
      ],
    );
  }
}
