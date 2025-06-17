import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart' show SizeConfig;

Widget buildEmptyStateWidget(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bookmark_border,
          size: SizeConfig().responsiveFont(48),
          color: ColorsManager.greyColor,
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        Text(
          AppStrings.noBookmarksTitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: SizeConfig().responsiveFont(18),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        Text(
          AppStrings.noBookmarksSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ColorsManager.greyColor,
            fontSize: SizeConfig().responsiveFont(14),
          ),
        ),
      ],
    ),
  );
}
