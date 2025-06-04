import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

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
            Text(AppKeyStringTr.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
             SizedBox(width: SizeConfig().width(0.05)),
            Text(plant.name, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
         SizedBox(height: SizeConfig().height(0.015)),
        Row(
          children: [
            Text(AppKeyStringTr.category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
             SizedBox(width: SizeConfig().width(0.05)),
            SizedBox(
              width: SizeConfig().width(0.5),
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
