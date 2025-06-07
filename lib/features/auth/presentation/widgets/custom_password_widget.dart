import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';
import '../manager/password_visibility_provider.dart';

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
    final passwordVisibilityProvider = Provider.of<PasswordVisibilityProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppKeyStringTr.password,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: SizeConfig().height(0.006)),
        BuildTextField(
          obscureText: passwordVisibilityProvider.obscureText,
          keyboardType: TextInputType.visiblePassword,
          controller: passwordController,
          validator: validatorController.passwordValid,
          hintText: AppKeyStringTr.enterPassword,
          prefixIcon: Icon(Icons.lock_outline, size: 18),
          suffixIcon: InkWell(

              onTap: () {
                passwordVisibilityProvider.toggleVisibility();
              },
              child: Icon( passwordVisibilityProvider.obscureText
                  ? Icons.visibility_off
                  : Icons.visibility, size: 18)),
        ),
      ],
    );
  }
}
