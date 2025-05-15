import 'package:flutter/material.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../config/theme/app_colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  final validatorController = ValidatorController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildLoginForm());
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig().height(0.08)),
              HeaderLoginWidget(),
              SizedBox(height: SizeConfig().height(0.022)),
              CustomEmailWidget(
                context: context,
                validatorController: validatorController,
                emailController: _emailController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              CustomPasswordWidget(
                validatorController: validatorController,
                passwordController: _passwordController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (v) {}),
                      Text(
                        AppKeyStringTr.rememberMe,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        RouteHelper.navigateTo(
                          ForgetPasswordView(
                            emailController: _emailController,
                            formKey: _formKey,
                          ),
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
                ],
              ),
              SizedBox(height: SizeConfig().height(0.03)),
              OutlinedButtonWidget(
                nameButton: AppKeyStringTr.login,
                onPressed: () async {

                },
                foregroundColor:
                Theme.of(context).colorScheme.onSecondary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: SizeConfig().height(0.08)),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppKeyStringTr.or),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: SizeConfig().height(0.01)),
              BuildSocialButton(label: AppKeyStringTr.continueWithGoogle, image: AssetsManager.logoGoogle, onPressed: (){}),
              SizedBox(height: SizeConfig().height(0.02)),
              BuildSocialButton(label: AppKeyStringTr.continueWithFacebook, image: AssetsManager.logoFacebook, onPressed: (){}),
              SizedBox(height: SizeConfig().height(0.015)),
            ],
          ),
        ),
      ),
    );
  }
}
