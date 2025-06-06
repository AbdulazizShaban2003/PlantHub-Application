import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '$label :',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorsManager.blackColor,
              )
          ),
           SizedBox(height: SizeConfig().height(0.01)),
          Text(value,style: TextStyle(
              color: ColorsManager.blackColor,
              fontSize: SizeConfig().responsiveFont(12),
          ),),
        ],
      ),
    );
  }
}
