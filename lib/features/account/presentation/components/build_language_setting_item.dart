import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/provider/language_provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';

Widget buildLanguageSettingItem(
    BuildContext context,
    LanguageProvider languageProvider,
    ) {
  return Container(
    margin: EdgeInsets.only(bottom: SizeConfig().height(0.03)),
    child: Row(
      children: [
        Icon(
          Icons.language,
          size: SizeConfig().responsiveFont(24),
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        SizedBox(width: SizeConfig().width(0.05)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.languageSettings.tr(),
                style: TextStyle(
                  fontSize: SizeConfig().responsiveFont(16),
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: SizeConfig().responsiveFont(18),
            color: Theme.of(context).disabledColor,
          ),
          onSelected: (String languageCode) async {
            await context.setLocale(Locale(languageCode));
            languageProvider.toggleLanguage();
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  SizedBox(width: SizeConfig().width(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.english.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig().responsiveFont(16),
                            color: context.locale.languageCode == 'en'
                                ? ColorsManager.greenPrimaryColor
                                : ColorsManager.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (context.locale.languageCode == 'en')
                    Icon(
                      Icons.check_circle,
                      color: ColorsManager.greenPrimaryColor,
                      size: SizeConfig().responsiveFont(20),
                    ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ar',
              child: Row(
                children: [
                  SizedBox(width: SizeConfig().width(0.02)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.arabic.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig().responsiveFont(16),
                            color: context.locale.languageCode == 'ar'
                                ? ColorsManager.greenPrimaryColor
                                : ColorsManager.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (context.locale.languageCode == 'ar')
                    Icon(
                      Icons.check_circle,
                      color: ColorsManager.greenPrimaryColor,
                      size: SizeConfig().responsiveFont(20),
                    ),
                ],
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig().width(0.03)),
          ),
          elevation: SizeConfig().height(0.01),
          offset: Offset(0, SizeConfig().height(0.05)),
        ),
      ],
    ),
  );
}