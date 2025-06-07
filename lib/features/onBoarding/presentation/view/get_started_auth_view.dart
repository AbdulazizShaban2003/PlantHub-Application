import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/asstes_manager.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import 'package:plant_hub_app/features/auth/presentation/views/sign_up_view.dart';
import 'package:plant_hub_app/features/onBoarding/presentation/widget/build_social_button.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/image_component.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../widget/title_get_started_widget.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsManager.backgroundGetStarted),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.055)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig().height(0.05)),
              ImageComponent(),
              SizedBox(height: SizeConfig().height(0.02)),
              TitleGetStartedView(),
              SizedBox(height: SizeConfig().height(0.1)),
              BuildSocialButton(
                label: AppKeyStringTr.continueWithGoogle,
                image: AssetsManager.logoGoogle,
                onPressed: () {},
              ),
              SizedBox(height: SizeConfig().height(0.03)),
              const Spacer(),
              OutlinedButtonWidget(
                nameButton: AppKeyStringTr.signUp,
                onPressed: () {
                  Navigator.push(context, RouteHelper.navigateTo(const SignUpView()));
                },
              ),
              SizedBox(height: SizeConfig().height(0.02)),
              OutlinedButtonWidget(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                nameButton: AppKeyStringTr.login,
                onPressed: () {
                  Navigator.pushReplacement(context, RouteHelper.navigateTo(const LoginView()));
                },
              ),
              const Spacer(),
              Text(
                AppKeyStringTr.privacyPolicyTermsOfService,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: SizeConfig().height(0.03)),
            ],
          ),
        ),
      ),
    );
  }
}
