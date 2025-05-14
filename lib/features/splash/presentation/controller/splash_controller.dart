import 'dart:async';
import 'package:flutter/material.dart';
class SplashController {
  Timer? _logoTimer;
  Timer? _loadingTimer;
  Timer? _navigationTimer;
  void showLogoImageController({
    required VoidCallback setState,
    required bool showLogoImage,
  }) {
    _logoTimer = Timer(Duration(milliseconds: 1000), setState);
  }
  void showLoadingController({
    required VoidCallback setState,
    required bool showLoading,
  }) {
    _loadingTimer = Timer(Duration(seconds: 3), setState);
  }
  void navigateToOnBoarding(BuildContext context) async{

  }
  void dispose() {
    _logoTimer?.cancel();
    _loadingTimer?.cancel();
    _navigationTimer?.cancel();
  }
}