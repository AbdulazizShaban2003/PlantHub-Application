import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

class HeaderLoginWidget extends StatelessWidget {
  const HeaderLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppKeyStringTr.titleLoginView,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
         SizedBox(height: SizeConfig().height(0.02)),
        Text(
            AppKeyStringTr.subtitleLoginView,
            style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
