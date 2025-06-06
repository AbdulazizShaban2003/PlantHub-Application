import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:provider/provider.dart';

import '../../../../core/cache/cache_network_image.dart';
import '../../view_model.dart';

class PlantCard extends StatelessWidget {
  final String plantId;
  final String imageUrl;
  final String description;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plantId,
    required this.imageUrl,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantViewModel>(context, listen: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (plantProvider.allPlants.isEmpty && !plantProvider.isLoading) {
        plantProvider.fetchAllPlants();
      }
    });
    return Padding(
      padding:  EdgeInsets.only(bottom: SizeConfig().height(0.02)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CacheNetworkImage(imageUrl: imageUrl, width: double.infinity,height: SizeConfig().height(0.25),),
            ),
            SizedBox(height: SizeConfig().height(0.01)),
            Text(
              description,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: SizeConfig().width(0.04),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

