import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/auth/presentation/manager/auth_provider.dart';
import 'package:plant_hub_app/features/auth/presentation/views/sign_up_view.dart';
import 'package:plant_hub_app/features/home/presentation/views/home_view.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/function/flush_bar_fun.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../../../onBoarding/presentation/widget/build_social_button.dart';
import '../controller/vaildator_auth_controller.dart';
import '../widgets/custom_email_widget.dart';
import '../widgets/custom_password_widget.dart';
import '../widgets/header_login_widget.dart';
import 'forget_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final validatorController = ValidatorController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthProviderManager>(context, listen: true);

    return Scaffold(
      body: authViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLoginForm(authViewModel),
    );
  }
  Widget _buildLoginForm(AuthProviderManager authViewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig().height(0.08)),
              const HeaderLoginWidget(),
              SizedBox(height: SizeConfig().height(0.022)),
              CustomEmailWidget(
                context: context,
                validatorController: validatorController,
                emailController: emailController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              CustomPasswordWidget(
                validatorController: validatorController,
                passwordController: passwordController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      RouteHelper.navigateTo(
                        ForgetPasswordView(),
                      ),
                    );
                  },
                  child: Text(
                    AppKeyStringTr.forgetPassword,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: ColorsManager.greenPrimaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig().height(0.03)),
              OutlinedButtonWidget(
                nameButton: AppKeyStringTr.login,
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await authViewModel.login(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      context: context,
                    );

                    if (authViewModel.user != null && authViewModel.isEmailVerified) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        RouteHelper.navigateTo(HomeView()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                foregroundColor: ColorsManager.whiteColor,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: SizeConfig().height(0.04)),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppKeyStringTr.or,style: TextStyle(fontSize: SizeConfig().responsiveFont(13))),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: SizeConfig().height(0.03)),
              BuildSocialButton(
                label: AppKeyStringTr.continueWithGoogle,
                image: AssetsManager.logoGoogle,
                onPressed: () async {
                  await authViewModel.signInWithGoogle(context);
                  if (authViewModel.user != null) {
                    FlushbarHelperTest.showSuccess(
                      context: context,
                      message: AppStrings.verificationEmailSent,
                    );
                   await Navigator.pushAndRemoveUntil(
                      context,
                      RouteHelper.navigateTo(HomeView()),
                          (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              SizedBox(height: SizeConfig().height(0.04)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppKeyStringTr.dontHaveAccount,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: SizeConfig().width(0.05)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        RouteHelper.navigateTo(const SignUpView()),
                      );
                    },
                    child: Text(
                      AppKeyStringTr.signUp,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: ColorsManager.greenPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig().height(0.01)),
            ],
          ),
        ),
      ),
    );
  }
}