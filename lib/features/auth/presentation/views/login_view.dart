import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../../../onBoarding/presentation/widget/build_social_button.dart';
import '../controller/vaildator_auth_controller.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_email_widget.dart';
import '../widgets/custom_password_widget.dart';
import '../widgets/header_login_widget.dart';
import 'forget_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

// Update the _LoginViewState class in login_view.dart
class _LoginViewState extends State<LoginView> {

  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(body: _buildLoginForm(authViewModel));
  }

  Widget _buildLoginForm(AuthViewModel authViewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: authViewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig().height(0.08)),
              HeaderLoginWidget(),
              SizedBox(height: SizeConfig().height(0.022)),
              CustomEmailWidget(
                context: context,
                validatorController: authViewModel.validatorController,
                emailController: authViewModel.emailController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              CustomPasswordWidget(
                validatorController: authViewModel.validatorController,
                passwordController: authViewModel.passwordController,
              ),
              SizedBox(height: SizeConfig().height(0.015)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
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
                            emailController: authViewModel.emailController,
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
                  if (authViewModel.formKey.currentState!.validate()) {
                    await authViewModel.login(
                      email: authViewModel.emailController.text.trim(),
                      password: authViewModel.emailController.text.trim(),
                      context: context,
                    );
                  }
                },
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
              SizedBox(height: SizeConfig().height(0.03)),
              BuildSocialButton(
                  label: AppKeyStringTr.continueWithGoogle,
                  image: AssetsManager.logoGoogle,
                  onPressed: () {}),
              SizedBox(height: SizeConfig().height(0.02)),
             Row(
               children: [
                 Text("Don't have an account? ",
                     style: Theme.of(context).textTheme.bodySmall),
               ],
             ),
              SizedBox(height: SizeConfig().height(0.015)),
            ],
          ),
        ),
      ),
    );
  }
}