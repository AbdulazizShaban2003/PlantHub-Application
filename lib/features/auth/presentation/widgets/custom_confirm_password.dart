
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';

class CustomConfirmPassword extends StatelessWidget {
   const CustomConfirmPassword({
    super.key,
    required this.context,
    required this.validatorController,
    required TextEditingController passwordController, required this.confirmPasswordController,
  }) : passwordController = passwordController;

  final BuildContext context;
  final ValidatorController validatorController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppKeyStringTr.confirmPassword, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: SizeConfig().height(0.006)),
         BuildTextField(
           obscureText: true,
                keyboardType: TextInputType.emailAddress,
                validator: validatorController.passwordValid,
                hintText: AppKeyStringTr.confirmPassword,
                controller: confirmPasswordController,
                preffixIcon: Icon(Icons.lock_outline, size: 20),
              )
      ],
    );
  }
}
