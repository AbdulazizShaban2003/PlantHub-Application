import 'package:flutter/material.dart';

import '../../../../core/utils/size_config.dart';
import '../../data/models/plant_model.dart';

class CustomPrayerPlant extends StatelessWidget {
  const CustomPrayerPlant({
    super.key,
    required this.plant,
  });

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Name :",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(width: 35),
            Text(plant.name, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text("Category :",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(width: 20),
            SizedBox(
              width: SizeConfig().width(0.7),
              child: Text(plant.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
            ),
          ],
        ),

      ],
    );
  }
}
