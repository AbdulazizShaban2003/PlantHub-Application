import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
class OnBoardingModelPage {
  final String image;
  final String title;
  final String subTitle;

  OnBoardingModelPage({
    required this.image,
    required this.title,
    required this.subTitle,
  });

  static List<OnBoardingModelPage> onBoardingScreens = [
    OnBoardingModelPage(
      image: AssetsManager.imageOnboarding1,
      title: AppKeyStringTr.titleOnBoardingPage1,
      subTitle: AppKeyStringTr.subtitleOnBoardingPage1,
    ),
    OnBoardingModelPage(
      image: AssetsManager.imageOnboarding2,
      title: AppKeyStringTr.titleOnBoardingPage2,
      subTitle: AppKeyStringTr.subtitleOnBoardingPage2,
    ),
    OnBoardingModelPage(
      image: AssetsManager.imageOnboarding3,
      title: AppKeyStringTr.titleOnBoardingPage3,
      subTitle: AppKeyStringTr.subtitleOnBoardingPage3,
    ),
  ];
}
