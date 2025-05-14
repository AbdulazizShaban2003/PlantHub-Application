import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/my_app.dart';
import 'core/cache/cache_helper.dart';
import 'core/service/service_locator.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  await sl<CacheHelper>().init();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: Locale('ar'),
      child: PlantHub(),
    ),
  );
}