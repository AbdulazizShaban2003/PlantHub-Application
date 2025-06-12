import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_header.dart';
import 'build_category_card.dart';

class ExplorePlantsCategory extends StatelessWidget {
  const ExplorePlantsCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildHeader(header: AppStrings.explorePlants, onTab: () {}),
        SizedBox(
          height: SizeConfig().height(0.8),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig().width(0.03)),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: SizeConfig().height(0.02),
              crossAxisSpacing: SizeConfig().width(0.04),
              childAspectRatio: 0.9,
              children: [
                buildCategoryCard(
                  context: context,
                  title: AppStrings.succulentsCacti,
                  imagePath: AssetsManager.succulentsCacti,
                  category: 'succulents',
                ),
                buildCategoryCard(
                  context: context,
                  title: AppStrings.floweringPlants,
                  imagePath: AssetsManager.flowers,
                  category: 'flowering',
                ),
                buildCategoryCard(
                  context: context,
                  title: AppStrings.trees,
                  imagePath: AssetsManager.trees,
                  category: 'trees',
                ),
                buildCategoryCard(
                  context: context,
                  title: AppStrings.fruits,
                  imagePath: AssetsManager.fruits,
                  category: 'fruits',
                ),
                buildCategoryCard(
                  context: context,
                  title: AppStrings.vegetables,
                  imagePath: AssetsManager.vegetables,
                  category: 'vegetables',
                ),
                buildCategoryCard(
                  context: context,
                  title: AppStrings.herbs,
                  imagePath: AssetsManager.herbs,
                  category: 'herbs',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
