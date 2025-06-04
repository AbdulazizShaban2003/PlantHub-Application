import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../data/models/climatic_condition_model.dart';
import '../sections/custom_condition_section.dart';

class ConditionsTab extends StatelessWidget {
  final ClimaticConditions conditions;

  const ConditionsTab({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConditionCard(
          icon: Icons.thermostat,
          title: AppKeyStringTr.temperature,
          value: conditions.temperature,
          color: ColorsManager.redColor,
        ),
        ConditionCard(
          icon: Icons.grass,
          title: AppKeyStringTr.soil,
          value: conditions.soil,
          color: ColorsManager.brownColor,
        ),
        ConditionCard(
          icon: Icons.water_drop,
          title: AppKeyStringTr.moisture,
          value: conditions.moisture,
          color: ColorsManager.lightBlueColor,
        ),
        ConditionCard(
          icon: Icons.warning,
          title: AppKeyStringTr.sensitivity,
          value: conditions.sensitivity ?? 'Not specified',
          color: ColorsManager.yellowColor,
        ),
      ],
    );
  }
}
