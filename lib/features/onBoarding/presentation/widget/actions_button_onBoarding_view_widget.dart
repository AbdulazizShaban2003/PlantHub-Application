import 'package:flutter/material.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart' show OutlinedButtonWidget;
import '../view/get_started_auth_view.dart';

class ActionOnBoardingViewWidget extends StatelessWidget {
  const ActionOnBoardingViewWidget({
    super.key,
    required this.controller,
    required this.index,
  });

  final PageController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (index != 2)
          Expanded(
            child: OutlinedButtonWidget(
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary
              ),
              foregroundColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              nameButton: AppKeyStringTr.skip,
              onPressed: () {
               Navigator.pushReplacement(context, RouteHelper.navigateTo(GetStartedScreen()));
              },
            ),
          )
        else
          SizedBox(),
        SizedBox(width: SizeConfig().width(0.05)),
        Expanded(
          child: OutlinedButtonWidget(
            nameButton:index != 2? AppKeyStringTr.kContinue: AppKeyStringTr.getStarted,
            onPressed: () async{
              index != 2? controller.nextPage(duration: Duration(microseconds: 5000),curve: Curves.easeIn,):Navigator.pushReplacement(context,RouteHelper.navigateTo(const GetStartedScreen()));
                })
          ),
    ]
        );
  }
}
