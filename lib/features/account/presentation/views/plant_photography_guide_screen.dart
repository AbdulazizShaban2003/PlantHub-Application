import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'dart:io';

import '../../../../core/utils/app_strings.dart';
import '../section/build_tips_section.dart';
import '../widgets/build_header_card.dart';


class PlantPhotographyGuideScreen extends StatefulWidget {
  const PlantPhotographyGuideScreen({super.key});

  @override
  _PlantPhotographyGuideScreenState createState() => _PlantPhotographyGuideScreenState();
}

class _PlantPhotographyGuideScreenState extends State<PlantPhotographyGuideScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,

        title: Text(
          AppStrings.appBarTitle,
          style: Theme.of(context).textTheme.bodyLarge
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeaderCard(),
            SizedBox(height: SizeConfig().height(0.02)),
            SizedBox(height: SizeConfig().height(0.02)),
            buildTipsSection(),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildStepsSection(),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildBestPracticesSection(),
          ],
        ),
      ),
    );
  }





  Widget _buildStepsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.stepsSectionTitle,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                fontWeight: FontWeight.bold,
                color: ColorsManager.greenPrimaryColor
              ),
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildStepItem(1, AppStrings.step1Title, AppStrings.step1Description),
            _buildStepItem(2, AppStrings.step2Title, AppStrings.step2Description),
            _buildStepItem(3, AppStrings.step3Title, AppStrings.step3Description),
            _buildStepItem(4, AppStrings.step4Title, AppStrings.step4Description),
            _buildStepItem(5, AppStrings.step5Title, AppStrings.step5Description),
            _buildStepItem(6, AppStrings.step6Title, AppStrings.step6Description),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: SizeConfig().width(0.08),
            height: SizeConfig().width(0.08),
            decoration: BoxDecoration(color: ColorsManager.greenPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig().responsiveFont(14),
                ),
              ),
            ),
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
                    color: Colors.grey[600],
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

  Widget _buildBestPracticesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.practicesSectionTitle,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
                fontWeight: FontWeight.bold,
                  color: ColorsManager.greenPrimaryColor

              ),
            ),
            SizedBox(height: SizeConfig().height(0.02)),
            _buildPracticeItem(Icons.wb_sunny, AppStrings.practice1Title, AppStrings.practice1Description),
            _buildPracticeItem(Icons.center_focus_strong, AppStrings.practice2Title, AppStrings.practice2Description),
            _buildPracticeItem(Icons.palette, AppStrings.practice3Title, AppStrings.practice3Description),
            _buildPracticeItem(Icons.zoom_in, AppStrings.practice4Title, AppStrings.practice4Description),
            _buildPracticeItem(Icons.straighten, AppStrings.practice5Title, AppStrings.practice5Description),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
          color: ColorsManager.greenPrimaryColor,

          size: SizeConfig().responsiveFont(22),
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
                    color: Colors.grey[600],
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

}