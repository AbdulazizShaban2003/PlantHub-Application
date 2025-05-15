import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/appBar_view.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../controller/operation_controller.dart';
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

final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
final _UsernameController = TextEditingController();

final validatorController = ValidatorController();

class _SignUpViewState extends State<SignUpView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig().height(0.045)),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Icon(
                    context.locale.languageCode == 'en'
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                  ),
                ),
                SizedBox(height: SizeConfig().height(0.065)),
                InputUsernameTextField(usernameController: _UsernameController),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomEmailWidget(
                  context: context,
                  validatorController: validatorController,
                  emailController: _emailController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomPasswordWidget(
                  validatorController: validatorController,
                  passwordController: _passwordController,
                ),
                SizedBox(height: SizeConfig().height(0.02)),
                CustomConfirmPassword(
                  context: context,
                  validatorController: validatorController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                ),
                SizedBox(height: SizeConfig().height(0.2)),
               OutlinedButtonWidget(
                        nameButton: AppKeyStringTr.signUp,
                        onPressed: () async {

                        },
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
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
