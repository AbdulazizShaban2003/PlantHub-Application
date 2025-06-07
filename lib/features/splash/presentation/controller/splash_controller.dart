import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/service/service_locator.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../home/presentation/views/home_view.dart';
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
    Future.delayed(const Duration(seconds: 4, milliseconds: 500), () async {
      final isVisited = await sl<CacheHelper>().getData(key: AppKeyStringTr.onBoarding) ?? false;

      FirebaseAuth.instance.authStateChanges().first.then((user) {
        if (user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            RouteHelper.navigateTo(HomeView()),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            RouteHelper.navigateTo(
              isVisited ? GetStartedScreen() : OnBoardingView(),
            ),
                (route) => false,
          );
        }
      });
    });

  }
  void dispose() {
    _logoTimer?.cancel();
    _loadingTimer?.cancel();
    _navigationTimer?.cancel();
  }
}
