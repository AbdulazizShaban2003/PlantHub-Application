import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plant_hub_app/features/auth/presentation/manager/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/asstes_manager.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/widgets/outlined_button_widget.dart';
import '../components/build_Text_field.dart';
import '../controller/vaildator_auth_controller.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKeyRestPassword = GlobalKey<FormState>();
  final _emailControllerRestPassword = TextEditingController();
  final ValidatorController _validatorController = ValidatorController();

  @override
  void dispose() {
    _emailControllerRestPassword.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    if (!_formKeyRestPassword.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthProviderManager>(context, listen: false);
    await authViewModel.forgotPassword(
      email: _emailControllerRestPassword.text.trim(),
      context: context,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: context.locale.languageCode == 'en'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          },
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Lottie.asset(
        AssetsManager.forgetPasswordImage,
        height: SizeConfig().height(0.15),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthProviderManager>(context);

    return Scaffold(
      body: authViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKeyRestPassword,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig().height(0.04)),
                _buildHeader(context),
                SizedBox(height: SizeConfig().height(0.03)),
                _buildIllustration(),
                SizedBox(height: SizeConfig().height(0.05)),
                _buildTitleSection(context),
                SizedBox(height: SizeConfig().height(0.05)),
                Text(
                  AppKeyStringTr.yourRegisteredEmail,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                BuildTextField(
                  validator: _validatorController.emailValid,
                  prefixIcon: const Icon(Icons.email_outlined, size: 16),
                  hintText: AppKeyStringTr.email,
                  controller: _emailControllerRestPassword,
                ),
                SizedBox(height: SizeConfig().height(0.04)),
                OutlinedButtonWidget(
                  nameButton: AppKeyStringTr.sendLink,
                  onPressed: () => _handlePasswordReset(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}