import 'package:flutter/material.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';

class CustomPasswordWidget extends StatelessWidget {
  const CustomPasswordWidget({
    super.key,
    required this.passwordController,
    required this.validatorController,
  });

  final TextEditingController passwordController;
  final ValidatorController validatorController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppKeyStringTr.password,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: SizeConfig().height(0.006)),
        BuildTextField(
          keyboardType: TextInputType.visiblePassword,
          controller: passwordController,
          validator: validatorController.passwordValid,
          hintText: AppKeyStringTr.enterPassword,
          preffixIcon: Icon(Icons.lock_outline, size: 20),
          suffixIcon: InkWell(child: Icon(Icons.visibility_off, size: 20)),
        ),
      ],
    );
  }
}
