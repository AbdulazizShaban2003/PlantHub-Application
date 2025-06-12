import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
class PlantCategoryCard extends StatelessWidget {
  final String title;
  final String image;

  const PlantCategoryCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.greyColor.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: ColorsManager.blackColor
                  )
                ),
              ),
            ),
            Image.asset(image,width: SizeConfig().width(0.1),height: SizeConfig().height(0.06), fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
