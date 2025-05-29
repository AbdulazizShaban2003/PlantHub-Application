import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plant_hub_app/features/auth/presentation/widgets/custom_email_widget.dart';
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
    required this.formKey,
  });

  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig().height(0.04)),
              Column(
                crossAxisAlignment:
                    context.locale.languageCode == 'ar'
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      context.locale.languageCode == 'ar'
                          ? Icons.arrow_back
                          : Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig().height(0.03)),

              Center(
                child: Lottie.asset(
                  AssetsManager.forgetPasswordImage,
                  height: SizeConfig().height(0.25),
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
                  if (formKey.currentState!.validate()) {
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
