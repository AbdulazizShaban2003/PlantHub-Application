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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeConfig().height(0.015)),
          Text(
            AppKeyStringTr.prayerPlant,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
           SizedBox(height: SizeConfig().height(0.015)),
          CustomPrayerPlant(plant: plant),
           SizedBox(height: SizeConfig().height(0.015)),
          SectionTitle(title: AppKeyStringTr.photoGallery, icon: Icons.image),
          ImageGallery(images: plant.listImage),
          SectionTitle(title: AppKeyStringTr.description, icon: Icons.description),
          Text(
            plant.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          SectionTitle(title: AppKeyStringTr.distribution, icon: Icons.location_on),
           SizedBox(height: SizeConfig().height(0.015)),
          Text(
            AppKeyStringTr.nativeDistribution,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
         SizedBox(height:  SizeConfig().height(0.015),),

          Text(
            plant.distribution.native,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: SizeConfig().height(0.015)),

          SizedBox(height: SizeConfig().height(0.015)),
          Text(
            AppKeyStringTr.currentDistribution,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
           SizedBox(height: SizeConfig().height(0.015)),
          AspectRatio(
            aspectRatio: 1.5,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 32,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final distribution = plant.distribution;
                return Text(
                  "${distribution.current[index]} ,",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              itemCount: plant.distribution.current.length,
            ),
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
    );
  }
}
