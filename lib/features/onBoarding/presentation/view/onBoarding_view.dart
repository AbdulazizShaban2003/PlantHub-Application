import 'package:flutter/material.dart';
import '../widget/onBoarding_index_pages_view.dart';
class OnBoardingView extends StatelessWidget {
  OnBoardingView({super.key});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: PageView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return OnBoardingIndexPages(index: index, controller: _controller);
          },
          controller: _controller,
        ),
      ),
    );
  }
}
