import 'package:flutter/material.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';

class CustomAskExpert extends StatelessWidget {
  const CustomAskExpert({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().height(0.17),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image(
            width: SizeConfig().width(0.4),
            image: AssetImage(AssetsManager.questionsBroImage),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig().width(0.01),
                vertical: SizeConfig().height(0.007),
              ),
              child: Column(
                children: [
                  Text(
                    AppKeyStringTr.askPlantExpert,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    AppKeyStringTr.subtitleAskPlantExpert,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontSize: SizeConfig().responsiveFont(10),
                    ),
                  ),
                  OutlinedButtonWidget(
                    style: Theme.of(context).textTheme.labelSmall,
                    nameButton: AppKeyStringTr.askPlantExpert,
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
