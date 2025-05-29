import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';

class CustomEmailWidget extends StatelessWidget {
  const CustomEmailWidget({
    super.key,
    required this.context,
    required this.validatorController,
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final BuildContext context;
  final ValidatorController validatorController;
  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppKeyStringTr.email, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: SizeConfig().height(0.006)),
        BuildTextField(
          keyboardType: TextInputType.emailAddress,
          hintText: AppKeyStringTr.email,
          validator: validatorController.emailValid,
          controller: _emailController,
          prefixIcon: Icon(Icons.email_outlined, size: 18),
        ),
      ],
    );
  }
}
