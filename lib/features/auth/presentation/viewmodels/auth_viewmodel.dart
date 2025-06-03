import 'dart:async';

import 'package:another_flushbar/flushbar.dart' show Flushbar;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/function/flush_bar_fun.dart';
import 'package:plant_hub_app/features/auth/presentation/views/login_view.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/errors/flush_bar.dart';
import '../../../home/presentation/views/home_view.dart';
import '../../domain/usecases/google_sign.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../controller/operation_controller.dart';
import '../controller/vaildator_auth_controller.dart';

class AuthViewModel with ChangeNotifier {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final OperationController operationController;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  AuthViewModel({
    required this.signUpUseCase,
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.operationController,
    required this.signInWithGoogleUseCase,
  });
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final validatorController = ValidatorController();
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
  }
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _setLoading(true);
    _setError(null);
    operationController.showLoadingDialog(context, 'Signing up...');
    try {
      await signUpUseCase.call(name: name, email: email, password: password);
      FlushbarHelper.showSuccess(context: context, message: 'Account created successfully!');
      Navigator.pop(context); // close loading dialog
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        Navigator.pushReplacement(context, RouteHelper.navigateTo(HomeView()));
      } else {
        FlushbarHelper.showWarning(
          context: context,
          message: 'Please verify your email before logging in.',
        );

        Navigator.pop(context);

        await Future.delayed(Duration(milliseconds: 100));
        Navigator.pushReplacement(context, RouteHelper.navigateTo(LoginView()));


      }
    } catch (e) {
      Navigator.pop(context);
      handleError(e, context);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await operationController.showLoadingDialog(context, 'Logging in...');
      await loginUseCase.call(email: email, password: password);
      Navigator.pop(context);

      FlushbarHelper.showSuccess(
        context: context, message: "Successfully logged in",);

      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        await Navigator.pushReplacement(
            context, RouteHelper.navigateTo(HomeView()));
      } else {
        FirebaseAuth.instance.currentUser!.sendEmailVerification();
        FlushbarHelper.showWarning(context: context,
          message: 'Please verify your email before logging in.',);
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      await handleError(e, context);
    } finally {
      _setLoading(false);
    }
  }
  Future<void> forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    _setLoading(true);
    _setError(null);
    operationController.showLoadingDialog(context, 'Sending reset link...');
    Navigator.of(context, rootNavigator: true).pop();
    if (email.isEmpty) {
      FlushbarHelper.showError(context: context, message: 'Please enter your email address',);
      _setLoading(false);
      return;
    }
    try {
      await forgotPasswordUseCase.call(email);

      Navigator.of(context, rootNavigator: true).pop(); // close dialog
      FlushbarHelper.showSuccess(context: context, message: 'Password reset link sent to your email');

      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.pop(context); // close forget password screen
        Navigator.pushReplacement(context, RouteHelper.navigateTo(LoginView()));
      });

    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // close dialog
      await handleError(e, context);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    _setError(null);
    operationController.showLoadingDialog(context, 'Signing in with Google...');

    try {
      await signInWithGoogleUseCase.call();
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      handleError(e, context);
    } finally {
      _setLoading(false);
    }
  }
}
