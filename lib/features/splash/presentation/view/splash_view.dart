import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:typewritertext/typewritertext.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../controller/splash_controller.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});
  @override
  State<SplashView> createState() => _SplashViewState();
}
class _SplashViewState extends State<SplashView> {
  bool showLogo = false;
  final SplashController _controller =SplashController();
  bool showLoading = false;
  @override
  void initState() {
    super.initState();
    _controller.showLogoImageController(
        setState: () => setState(() => showLogo = true),
        showLogoImage: showLogo,
    );
    _controller.showLoadingController(
        setState: () => setState(() => showLoading = true),
        showLoading: showLoading,
    );

    _controller.navigateToOnBoarding(context);
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.greenPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedOpacity(
              opacity: showLogo ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: SizedBox(
                width: 200,
                child: Image(
                  image: AssetImage(AssetsManager.logoApp),
                ),
              ),
            ),
            SizedBox(height: SizeConfig().height(0.07)),
            SizedBox(
              width: double.infinity,
              child: TypeWriter.text(
                AppKeyStringTr.nameApp,
                textAlign: TextAlign.center,
                style:Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: ColorsManager.whiteColor
                ),
                duration: const Duration(milliseconds: 100),
              ),
            ),
            const Spacer(),
            if (showLoading)
              AnimatedScale(
                scale: showLoading ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 800),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SpinKitWave(
                    color: ColorsManager.whiteColor,
                    size: SizeConfig().height(0.030),
                  ),
                ),
              ),
            SizedBox(height: SizeConfig().height(0.05)),
          ],
        ),
      ),
    );
  }
}