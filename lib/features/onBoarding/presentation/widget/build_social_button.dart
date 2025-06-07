import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../config/theme/app_colors.dart';

class BuildSocialButton extends StatelessWidget {
  const BuildSocialButton({super.key, required this.label, required this.image, required this.onPressed});

  final String label;
  final String image;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      
      textDirection: TextDirection.ltr,
      child: TextButton.icon(
        style: OutlinedButton.styleFrom(
        minimumSize:  Size(double.infinity, SizeConfig().height(0.07)),
        ),
          onPressed: onPressed,
          icon: Image(image: AssetImage(image)),
          label: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
      ),
    );
  }

}