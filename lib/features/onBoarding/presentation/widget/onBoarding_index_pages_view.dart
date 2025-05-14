import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/onBoarding/presentation/widget/title_onBoarding_view_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/utils/size_config.dart';
import 'actions_button_onBoarding_view_widget.dart' show ActionOnBoardingViewWidget;
import 'image_onBoarding_view_widget.dart' show ImagesOnBoardingViewWidget;
import '../../data/model/onBoarding_model_pages.dart';
class OnBoardingIndexPages extends StatelessWidget {
  const OnBoardingIndexPages({super.key, required this.index, required this.controller});

  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImagesOnBoardingViewWidget(
          image: OnBoardingModelPage.onBoardingScreens[index].image,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TitleOnBoardingViewWidget(
                title: OnBoardingModelPage.onBoardingScreens[index].title,
                subTitle: OnBoardingModelPage.onBoardingScreens[index].subTitle,
              ),
              SizedBox(height: SizeConfig().height(0.04)),
              SmoothPageIndicator(
                controller: controller,
                count: OnBoardingModelPage.onBoardingScreens.length,
                effect: ExpandingDotsEffect(
                  dotWidth: SizeConfig().width(0.03),
                  dotHeight: SizeConfig().height(0.01),
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Theme.of(context).colorScheme.onSurface
                ),
              ),
              SizedBox(height: SizeConfig().height(0.06)),
              Divider(),
              SizedBox(height: SizeConfig().height(0.01)),
              ActionOnBoardingViewWidget(controller: controller, index: index,),
              SizedBox(height: SizeConfig().height(0.006)),
            ],
          ),
        ),
      ],
    );
  }
}
