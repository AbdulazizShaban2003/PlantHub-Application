import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../controller/home_controller.dart';
import '../components/build_header.dart';
import 'custom_category_card.dart';

class CustomExplorePlant extends StatelessWidget {
  const CustomExplorePlant({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildHeader(header: AppKeyStringTr.explorePlants),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: SizeConfig().width(0.05),
            mainAxisSpacing: SizeConfig().height(0.025),
            childAspectRatio: 2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return PlantCategoryCard(
              title: categories[index]['title']!,
              image: categories[index]['image']!,
            );
          },
        ),
      ],
    );
  }
}
