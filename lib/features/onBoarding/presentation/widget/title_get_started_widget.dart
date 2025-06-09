import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

class TitleGetStartedView extends StatelessWidget {
  const TitleGetStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppKeyStringTr.titleForGetStarted,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: ColorsManager.whiteColor
          ),
        ),
        SizedBox(height: SizeConfig().height(0.008)),
        Text(
          AppKeyStringTr.subtitleForGetStarted,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: ColorsManager.whiteColor,
          ),
        ),
      ],
    );
  }
}
