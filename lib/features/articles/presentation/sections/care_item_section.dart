import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../config/theme/app_colors.dart';

class CareItem extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const CareItem({super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:  EdgeInsets.only(bottom: SizeConfig().height(0.015)),
      child: ListTile(
        leading: Icon(icon, color: ColorsManager.greenPrimaryColor),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold,color: ColorsManager.blackColor,fontSize: SizeConfig().responsiveFont(15)),
        ),
        subtitle: Padding(
          padding:  EdgeInsets.only(top: SizeConfig().height(0.01)),
          child: Text(content,style: TextStyle(
              color: ColorsManager.blackColor,
              fontSize: SizeConfig().responsiveFont(12),
            fontWeight: FontWeight.w100,
          ),),
        ),
        minVerticalPadding: 16,
      ),
    );
  }
}
