import 'package:flutter/material.dart';

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
          SizedBox(height: 16),
          Text(
            "Prayer Plant",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          CustomPrayerPlant(plant: plant),
          const SizedBox(height: 16),
          SectionTitle(title: 'Photo Gallery', icon: Icons.image),
          ImageGallery(images: plant.listImage),
          SectionTitle(title: 'Description', icon: Icons.description),
          Text(
            plant.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          SectionTitle(title: 'Distribution', icon: Icons.location_on),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Native Distribution:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plant.distribution.native,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Current Distribution:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 100,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3,
              ),
              itemBuilder: (context, index) {
                final distribution = plant.distribution;
                return Text(
                  distribution.current[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              itemCount: plant.distribution.current.length,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/mapping.jpg",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade100.withOpacity(0.7),
                        ),
                      ),
                      title: Text("Potential Invasive"),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100.withOpacity(0.7),
                        ),
                      ),
                      title: Text("Native"),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.shade100.withOpacity(0.7),
                        ),
                      ),
                      title: Text("Cultivated"),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.shade100.withOpacity(0.7),
                        ),
                      ),
                      title: Text("No species Reported"),
                    ),
                  ),
                ],
              )

            ],
          ),
          const SizedBox(height: 45),
          SectionTitle(title: 'Ask an Expert', icon: Icons.help_outline),
          const SizedBox(height: 25),
          const CustomAskExpert(),
          const SizedBox(height: 25),
          Divider(
            color: ColorsManager.greyColor,
            thickness: 1,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
