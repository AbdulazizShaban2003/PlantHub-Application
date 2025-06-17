import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/function/flush_bar_fun.dart';
import 'package:plant_hub_app/features/auth/presentation/manager/auth_provider.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import 'package:plant_hub_app/features/auth/presentation/widgets/trem_agree_widget.dart';
import 'package:provider/provider.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../../../home/presentation/views/home_view.dart';
import '../controller/vaildator_auth_controller.dart';
import '../widgets/custom_confirm_password.dart';
import '../widgets/custom_email_widget.dart';
import '../widgets/custom_password_widget.dart';
import '../widgets/input_username_text_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final validatorController = ValidatorController();

  bool _isShowingErrorDialog = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProviderManager>(context, listen: false)
          .addListener(_handleAuthErrors);
    });
  }

  // Remove listener in dispose
  @override
  void deactivate() {
    Provider.of<AuthProviderManager>(context, listen: false)
        .removeListener(_handleAuthErrors);
    super.deactivate();
  }

  void _handleAuthErrors() {
    final authViewModel = Provider.of<AuthProviderManager>(context, listen: false);
    if (authViewModel.error != null && !_isShowingErrorDialog) {
      if (authViewModel.error.toString().contains("unusual activity")) {
        _isShowingErrorDialog = true; // Set flag to true to prevent multiple dialogs
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Sign Up Error"),
              content: Text(authViewModel.error!),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _isShowingErrorDialog = false;
                    Navigator.pushAndRemoveUntil(
                      context,
                      RouteHelper.navigateTo(const LoginView()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ).then((_) {

          _isShowingErrorDialog = false;
        });
      } else if (authViewModel.error == AppStrings.emailNotVerified) {
        FlushbarHelperTest.showError(
          context: context,
          message: authViewModel.error!,
        );

      } else {
        FlushbarHelperTest.showError(
          context: context,
          message: authViewModel.error!,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthProviderManager>(
      context,
      listen: true,
    );

    return Scaffold(
      body:
      authViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig().height(0.045)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    context.locale.languageCode == 'en'
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.045)),
                Text(
                  AppStrings.joinPlantHub,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: SizeConfig().height(0.012)),
                Text(
                  AppStrings.createAccount,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: SizeConfig().height(0.035)),
                InputUsernameTextField(
                  usernameController: usernameController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomEmailWidget(
                  context: context,
                  validatorController: validatorController,
                  emailController: emailController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomPasswordWidget(
                  validatorController: validatorController,
                  passwordController: passwordController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomConfirmPassword(
                  context: context,
                  validatorController: validatorController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                ),

                SizedBox(height: SizeConfig().height(0.08)),

                OutlinedButtonWidget(
                  nameButton: AppKeyStringTr.signUp,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (passwordController.text !=
                          confirmPasswordController.text) {
                        FlushbarHelperTest.showError(
                          context: context,
                          message: AppStrings.passwordsNotMatch,
                        );
                        return;
                      }

                      await authViewModel.signUp(
                        name: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        context: context,
                      );

                      if (authViewModel.user != null && authViewModel.user!.isEmailVerified) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          RouteHelper.navigateTo(const HomeView()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  foregroundColor: ColorsManager.whiteColor,
                  backgroundColor:
                  Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: SizeConfig().height(0.03)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}