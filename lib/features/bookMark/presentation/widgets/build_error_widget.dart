import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/app_strings.dart';

import '../../../../core/utils/size_config.dart';

Widget buildErrorWidget(Object error,BuildContext context,VoidCallback refreshData) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline,
            size: SizeConfig().responsiveFont(48),
            color: ColorsManager.redColor),
        SizedBox(height: SizeConfig().height(0.02)),
        Text(AppStrings.failedToLoadBookmarks,
            style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
        Text(
          AppStrings.tryAgainLater,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: SizeConfig().responsiveFont(14)),
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        ElevatedButton(
          onPressed: refreshData,
          child: Text(AppStrings.retry,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(16))),
        )
      ],
    ),
  );
}
