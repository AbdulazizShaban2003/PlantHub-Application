import 'package:flutter/material.dart';
import '../../../../core/utils/size_config.dart';
class TitleOnBoardingViewWidget extends StatelessWidget {
  const TitleOnBoardingViewWidget({super.key, required this.title, required this.subTitle});
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium
        ),
         SizedBox(height: SizeConfig().height(0.02)),
         Text(
          subTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
