import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('ar');
      Restart.restartApp();
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }
}
