import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/auth/presentation/views/forget_password_view.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import 'package:plant_hub_app/features/auth/presentation/views/sign_up_view.dart';
import 'package:plant_hub_app/features/home/presentation/views/home_view.dart';
import 'package:plant_hub_app/features/onBoarding/presentation/view/onBoarding_view.dart';
import 'package:plant_hub_app/features/splash/presentation/view/splash_view.dart';
import '../config/theme/app_theme.dart';
import '../core/utils/size_config.dart';
class PlantHub extends StatefulWidget {
  const PlantHub({super.key});
  @override
  State<PlantHub> createState() => _PlantHubState();
}
class _PlantHubState extends State<PlantHub> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return  MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            darkTheme: AppThemes.darkTheme,
            themeMode: ThemeMode.dark,
            theme: AppThemes.darkTheme,
            home: HomeView()
    );
  }
}
