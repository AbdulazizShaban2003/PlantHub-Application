import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/presentation/views/article_plant_view.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key, required this.header, required this.onTab});

  final String header;
  final VoidCallback onTab;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(header, style: Theme.of(context).textTheme.bodySmall),
        InkWell(
          onTap:onTab,
          child: Row(
            children: [
              Text(
                AppKeyStringTr.viewAll,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: ColorsManager.greenPrimaryColor,
                ),
              ),
              SizedBox(width: SizeConfig().width(0.03)),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? CupertinoIcons.arrow_left
                    : CupertinoIcons.arrow_right,
                color: ColorsManager.greenPrimaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
