import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';

import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../auth/presentation/views/login_view.dart';

class loginAccountViewBookMark extends StatelessWidget {
  const loginAccountViewBookMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: SizeConfig().responsiveFont(48),
            color: ColorsManager.redColor,
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          Text(
            AppStrings.pleaseLoginToViewYouBookmark,
            style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
          ),
          SizedBox(height: SizeConfig().height(0.02)),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                RouteHelper.navigateTo(LoginView()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text(
              AppKeyStringTr.login,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(16)),
            ),
          ),
        ],
      ),
    );
  }
}
