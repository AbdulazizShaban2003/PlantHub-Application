import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/provider/language_provider.dart';
import '../../../../core/utils/size_config.dart';

Widget buildLanguageSettingItem(BuildContext context, LanguageProvider languageProvider) {
  return Container(
    margin: const EdgeInsets.only(bottom: 25),
    child: Row(
      children: [
        Icon(
          Icons.language,
          size: 24,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Language settings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).disabledColor,
          ),
          onSelected: (String languageCode) async {
            languageProvider.toggleLanguage();
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'English',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: context.locale.languageCode == 'en'
                                ? Colors.green[700]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (context.locale.languageCode == 'en')
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
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
                          'Arabic',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: context.locale.languageCode == 'ar'
                                ? ColorsManager.greenPrimaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (context.locale.languageCode == 'ar')
                    Icon(
                      Icons.check_circle,
                      color: ColorsManager.greenPrimaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          offset: const Offset(0, 40), // إضافة const
        ),
      ],
    ),
  );
}
