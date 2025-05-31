import 'package:flutter/material.dart';

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
          title: 'Temperature',
          value: conditions.temperature,
          color: Colors.red,
        ),
        ConditionCard(
          icon: Icons.grass,
          title: 'Soil',
          value: conditions.soil,
          color: Colors.brown,
        ),
        ConditionCard(
          icon: Icons.water_drop,
          title: 'Moisture',
          value: conditions.moisture,
          color: Colors.lightBlue,
        ),
        ConditionCard(
          icon: Icons.warning,
          title: 'Sensitivity',
          value: conditions.sensitivity ?? 'Not specified',
          color: Colors.orange,
        ),
      ],
    );
  }
}
