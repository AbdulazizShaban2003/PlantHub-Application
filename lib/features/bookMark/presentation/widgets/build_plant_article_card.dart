import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../../core/cache/cache_network_image.dart';
import '../../../articles/data/models/plant_model.dart';
import '../../../articles/presentation/views/article_plant_details_view.dart';
import 'bookmark_button.dart';

Widget buildPlantCard(Plant plant, BuildContext context) {
  return Container(
    height: SizeConfig().height(0.4),
    margin: EdgeInsets.only(bottom: SizeConfig().height(0.02)),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          RouteHelper.navigateTo(
            ArticlePlantDetailsView(plantId: plant.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
                  child: CacheNetworkImage(
                    imageUrl: plant.image,
                    width: double.infinity,
                    height: SizeConfig().height(0.25),
                  )
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig().width(0.03)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          plant.description,
                          style: TextStyle(
                              fontSize: SizeConfig().responsiveFont(14),
                              color: Theme.of(context).primaryColor
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: SizeConfig().height(0.01),
            right: SizeConfig().width(0.02),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsManager.whiteColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(SizeConfig().width(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.blackColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: BookmarkButton(
                itemId: plant.id,
                size: SizeConfig().responsiveFont(20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}