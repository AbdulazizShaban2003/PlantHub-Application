import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';
import 'package:plant_hub_app/core/utils/asstes_manager.dart';

import '../../../../core/utils/size_config.dart';

class CustomNoPlantWidget extends StatelessWidget {
  const CustomNoPlantWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig().height(0.1), bottom: SizeConfig().height(0.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(AssetsManager.noSearchImage),
            height: SizeConfig().height(0.25),
          ),
          Text(
            AppKeyStringTr.noPlantFound,
            textAlign: TextAlign.center,
            style: Theme .of(context).textTheme.headlineMedium
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            AppKeyStringTr.noPlantFoundDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ColorsManager.greyColor,
          ),
          )
        ],
      ),
    );
  }
}
