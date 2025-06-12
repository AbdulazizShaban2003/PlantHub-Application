import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../core/utils/app_strings.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceMaterialTransparency: true,
            forceElevated: true,
            title: Text(
              AppStrings.privacyPolicyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),


          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildContent(context),
                childCount: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig().height(0.02)),
        Text(
          AppStrings.lastUpdated,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        Text(
          AppStrings.introText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: SizeConfig().height(0.03)),
        Text(
          AppStrings.infoWeCollect,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        _buildBulletPoint(AppStrings.personalInfo, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.plantPhotos, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.usageData, context),
        SizedBox(height: SizeConfig().height(0.03)),
        Text(
          AppStrings.howWeUse,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.016)),
        _buildBulletPoint(AppStrings.plantIdentification, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.diseaseDiagnosis, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.personalization, context),
        SizedBox(height: SizeConfig().height(0.03)),
        Text(
          AppStrings.dataProtection,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.016)),
        _buildBulletPoint(AppStrings.dataEncrypted, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.localProcessing, context),
        SizedBox(height: SizeConfig().height(0.03)),
        Text(
          AppStrings.yourRights,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.016)),
        _buildBulletPoint(AppStrings.accessInfo, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.optOut, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.deletePhotos, context),
        SizedBox(height: SizeConfig().height(0.03)),
        Text(
          AppStrings.contactUs,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SizeConfig().height(0.016)),
        _buildBulletPoint(AppStrings.emailUs, context),
        SizedBox(height: SizeConfig().height(0.01)),
        _buildBulletPoint(AppStrings.contactSupport, context),
        SizedBox(height: SizeConfig().height(0.03)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:  ColorsManager.greenPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:   ColorsManager.greenPrimaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            AppStrings.commitmentText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: ColorsManager.greenPrimaryColor,
            ),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.03)),
      ],
    );
  }

  Widget _buildBulletPoint(String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          '• ',
          style: TextStyle(
            fontSize: SizeConfig().responsiveFont(14),
            color: ColorsManager.greenPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: SizeConfig().height(0.01)),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}