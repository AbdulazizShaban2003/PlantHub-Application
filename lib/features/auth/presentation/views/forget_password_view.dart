import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';

import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../components/build_Text_field.dart';
import '../controller/operation_controller.dart';
import '../controller/vaildator_auth_controller.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({
    super.key,
    required this.emailController,
    required this.formKey,
  });

  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

final operationController = OperationController();

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  @override
  Widget build(BuildContext context) {
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
                onTap: (){
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
                preffixIcon: Icon(Icons.email_outlined),
                hintText: AppKeyStringTr.email,
                controller: widget.emailController,
              ),
              SizedBox(height: SizeConfig().height(0.15)),
              OutlinedButtonWidget(
                nameButton: AppKeyStringTr.sendLink,
                onPressed: () {},
              ),
              SizedBox(height: SizeConfig().height(0.01)),
            ],
          ),
        ),
      ),
    );
  }
}
