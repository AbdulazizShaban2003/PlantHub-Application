import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../home/presentation/widgets/custom_ask_expert.dart';
import '../../data/models/plant_model.dart';
import '../sections/title_section.dart';
import '../sections/custom_image_gallery.dart';
import 'custom_prayer_plant.dart';

class OverviewTab extends StatelessWidget {
  final Plant plant;

  const OverviewTab({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig().height(0.015)),
            Text(
              AppKeyStringTr.prayerPlant,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
             SizedBox(height: SizeConfig().height(0.015)),
            CustomPrayerPlant(plant: plant),
             SizedBox(height: SizeConfig().height(0.015)),
            SectionTitle(title: AppKeyStringTr.photoGallery, icon: Icons.image),
            ImageGallery(images: plant.listImage),
            SectionTitle(title: AppKeyStringTr.description, icon: Icons.description),
            Text(
              plant.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),

            SectionTitle(title: AppKeyStringTr.distribution, icon: Icons.location_on),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  AppKeyStringTr.nativeDistribution,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                  SizedBox(width: SizeConfig().width(0.05)),
                Expanded(
                  child: Text(
                    plant.distribution.native,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            Text(
              AppKeyStringTr.currentDistribution,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: SizeConfig().height(0.02)),
            Wrap(
              spacing: 32,
              runSpacing: 16,
              children: plant.distribution.current.map((item) {
                return Text(
                  "$item,",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
               SizedBox(height: SizeConfig().height(0.015)),
            SectionTitle(title: AppKeyStringTr.askPlantExpert, icon: Icons.help_outline),
             SizedBox(height: SizeConfig().height(0.015)),
            const CustomAskExpert(),
             SizedBox(height: SizeConfig().height(0.015)),
            Divider(),
            SizedBox(height:SizeConfig().height(0.015)),
          ],
        ),
      ),
    );
  }
}
