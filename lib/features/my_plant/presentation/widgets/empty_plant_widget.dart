import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/asstes_manager.dart';

import '../../../../core/utils/size_config.dart';
import '../views/add_plant_screen.dart';

class EmptyPlantsWidget extends StatelessWidget {
  const EmptyPlantsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage(AssetsManager.iconPlant),height: SizeConfig().height(0.125),),
          SizedBox(height: SizeConfig().height(0.03)),
          Text(
            'You Have No Plants',
            style: Theme.of(context).textTheme.bodyLarge
          ),
          SizedBox(height: SizeConfig().height(0.01)),
          Text(
            'You haven\'t added any plants yet',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: SizeConfig().height(0.04)),
        ],
      ),
    );
  }
}
