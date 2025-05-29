import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/function/flush_bar_fun.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../controller/vaildator_auth_controller.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_confirm_password.dart';
import '../widgets/custom_email_widget.dart';
import '../widgets/custom_password_widget.dart';
import '../widgets/input_username_text_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}
final formKey = GlobalKey<FormState>();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();
final usernameController = TextEditingController();
final validatorController = ValidatorController();
class _SignUpViewState extends State<SignUpView> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      body: Padding(
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
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    context.locale.languageCode == 'en'
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.045)),
                Text(
                  "Join PlantHub Today 👨‍🌾",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: SizeConfig().height(0.01)),
                Text(
                  "Create an account to explore a world of plants and gardening tips.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: SizeConfig().height(0.035)),
                InputUsernameTextField(
                  usernameController: authViewModel.usernameController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomEmailWidget(
                  context: context,
                  validatorController: validatorController,
                  emailController:emailController,
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
                  confirmPasswordController:
                  confirmPasswordController,
                ),
                SizedBox(height: SizeConfig().height(0.08)),
                OutlinedButtonWidget(
                  nameButton: AppKeyStringTr.signUp,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (passwordController.text !=
                          confirmPasswordController.text) {
                        FlushbarHelper.showError(
                          context: context,
                          message: 'Passwords do not match',
                        );
                      }

                      await authViewModel.signUp(
                        name: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        context: context,
                      );
                    }
                  },
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
