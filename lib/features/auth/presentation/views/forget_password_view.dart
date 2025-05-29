import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';
import '../viewmodels/auth_viewmodel.dart';
class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig().height(0.04)),
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
              Center(
                child: Lottie.asset(
                  AssetsManager.forgetPasswordImage,
                  height: SizeConfig().height(0.3),
                ),
              ),
              SizedBox(height: SizeConfig().height(0.05)),
              Text(
                AppKeyStringTr.titleForgetPassword,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: SizeConfig().height(0.02)),
              Text(
                AppKeyStringTr.subtitleForgetPassword,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: SizeConfig().responsiveFont(13),
                ),
              ),
              SizedBox(height: SizeConfig().height(0.05)),
              Text(
                AppKeyStringTr.yourRegisteredEmail,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: SizeConfig().height(0.02)),
              BuildTextField(
                validator: ValidatorController().emailValid,
                prefixIcon: Icon(Icons.email_outlined, size: 18),
                hintText: AppKeyStringTr.email,
                controller: emailController,
              ),
              SizedBox(height: SizeConfig().height(0.06)),
              OutlinedButtonWidget(
                nameButton: AppKeyStringTr.sendLink,
                onPressed: () async {
                  if (authViewModel.formKey.currentState!.validate()) {
                    await authViewModel.forgotPassword(
                      email: emailController.text.trim(),
                      context: context,
                    );
                  }
                },
              ),
              SizedBox(height: SizeConfig().height(0.01)),
            ],
          ),
        ),
      ),
    );
  }
}
