import 'package:flutter/material.dart';
import '../../../../core/utils/size_config.dart';
import '../controller/onBoarding_controller.dart';
class ImagesOnBoardingViewWidget extends StatefulWidget {
  const ImagesOnBoardingViewWidget({
    super.key, required this.image,
  });
final String image;

  @override
  State<ImagesOnBoardingViewWidget> createState() => _ImagesOnBoardingViewWidgetState();
}

class _ImagesOnBoardingViewWidgetState extends State<ImagesOnBoardingViewWidget>    with SingleTickerProviderStateMixin {
  late final OnBoardingController _onBoardingController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _onBoardingController = OnBoardingController(vsync: this);
  }

  @override
  void dispose() {
    _onBoardingController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: SizeConfig().height(0.06),
      child: FadeTransition(
        opacity: _onBoardingController.fadeAnimation,
        child: SlideTransition(
          position: _onBoardingController.slideAnimation,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image(image: AssetImage(widget.image)
            )
          ),
        ),
      ),
    );
  }
}
