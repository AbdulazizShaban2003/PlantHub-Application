import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/service/service_locator.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../onBoarding/presentation/view/get_started_auth_view.dart';
import '../../../onBoarding/presentation/view/onBoarding_view.dart';
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
  void navigateToOnBoarding(BuildContext context) async {
    bool isVisited = await sl<CacheHelper>().getData(key: AppKeyStringTr.onBoarding) ?? false;
    Future.delayed(const Duration(seconds: 4,milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        RouteHelper.navigateTo(
          isVisited ? GetStartedScreen() : OnBoardingView(),
        ),
      );
    });
  }
  void dispose() {
    _logoTimer?.cancel();
    _loadingTimer?.cancel();
    _navigationTimer?.cancel();
  }
}