import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

Widget buildTipsSection() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
    ),
    child: Padding(
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tipsSectionTitle,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(18),
              fontWeight: FontWeight.bold,
              color: ColorsManager.greenPrimaryColor,
            ),
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          _buildTipItem('🌅', AppStrings.tip1Title, AppStrings.tip1Description),
          _buildTipItem('💧', AppStrings.tip2Title, AppStrings.tip2Description),
          _buildTipItem('🔍', AppStrings.tip3Title, AppStrings.tip3Description),
          _buildTipItem('📐', AppStrings.tip4Title, AppStrings.tip4Description),
        ],
      ),
    ),
  );
}
Widget _buildTipItem(String emoji, String title, String description) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            emoji,
            style: TextStyle(fontSize: SizeConfig().responsiveFont(20))
        ),
        SizedBox(width: SizeConfig().width(0.03)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig().responsiveFont(16),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: ColorsManager.greyColor[600],
                  fontSize: SizeConfig().responsiveFont(14),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
