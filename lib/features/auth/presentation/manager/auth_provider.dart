import 'package:another_flushbar/flushbar_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/auth/data/models/user_model.dart';
import 'package:plant_hub_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../config/routes/route_helper.dart';
import '../../../../core/function/flush_bar_fun.dart';
import '../../../../core/utils/app_strings.dart';
import '../controller/operation_controller.dart';
import '../views/login_view.dart';
class AuthProviderManager with ChangeNotifier {
  final AuthRepository _repository;
  final OperationController operationController;

  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  bool _isEmailVerified = false;

  AuthProviderManager({
    required AuthRepository repository,
    required this.operationController,
  }) : _repository = repository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  bool get isEmailVerified => _isEmailVerified;

  Future<void> verifyEmail(BuildContext context) async {
    _setLoading(true);
    final result = await _repository.checkEmailVerification();

    result.fold(
          (error) {
        _setError(error);
        FlushbarHelperTest.showError(context: context, message: error);
      },
          (verified) {
        _isEmailVerified = verified;
        if (verified) {
          FlushbarHelperTest.showSuccess(
            context: context,
            message: AppStrings.emailVerifiedSuccess,
          );
        } else {
          FlushbarHelperTest.showInfo(
            context: context,
            message: AppStrings.emailNotVerified,
          );
        }
        notifyListeners();
      },
    );
    _setLoading(false);
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    _setLoading(true);
    final result = await _repository.sendEmailVerification();

    result.fold(
          (error) {
        _setError(error);
        FlushbarHelperTest.showError(context: context, message: error);
      },
          (_) {
        FlushbarHelperTest.showSuccess(
          context: context,
          message: AppStrings.verificationEmailResent,
        );
      },
    );
    _setLoading(false);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, AppStrings.signingUp);
      final result = await _repository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      Navigator.pop(context);

      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelperTest.showError(context: context, message: AppStrings.verificationEmailSent);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginView()),
                (Route<dynamic> route) => false,
          );
          FlushbarHelperTest.showSuccess(context: context, message: AppStrings.verificationEmailSent);

        },
            (user) async {
          _setUser(user);
          final verificationResult = await _repository.sendEmailVerification();
          verificationResult.fold(
                (error) => FlushbarHelperTest.showError(context: context, message: error),
                (_) => FlushbarHelperTest.showSuccess(
              context: context,
              message: AppStrings.verificationEmailSent,
            ),
          );
        },
      );
    } catch (e) {
      _setError(AppStrings.unexpectedError);
      FlushbarHelperTest.showError(
        context: context,
        message: '${AppStrings.accountCreationFailed}${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, AppStrings.loggingIn);

      final result = await _repository.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pop(context);

      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelperTest.showError(context: context, message: error);
        },
            (user) async {
          _setUser(user);

          final verificationResult = await _repository.checkEmailVerification();


          verificationResult.fold(
                (error) => FlushbarHelperTest.showError(context: context, message: error),
                (verified) {
              _isEmailVerified = verified;
              if (verified) {
                FlushbarHelperTest.showSuccess(
                  context: context,
                  message: AppStrings.loginSuccess,
                );
              } else {
                _repository.sendEmailVerification();
                FlushbarHelperTest.showWarning(
                  context: context,
                  message: AppStrings.verifyEmailFirst,
                );
              }
              notifyListeners();
            },
          );
        },
      );
    } catch (e) {
      _setError(AppStrings.loginFailed);
      FlushbarHelperTest.showError(
        context: context,
        message: '${AppStrings.failedToLogin}${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forgotPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, AppStrings.validatingEmail);

      String cleanEmail = email.trim().toLowerCase();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Navigator.pop(context);
        _setError(AppStrings.emailNotFound);
        FlushbarHelperTest.showError(
          context: context,
          message: AppStrings.noAccountFound,
        );
        return;
      }

      operationController.showLoadingDialog(context, AppStrings.sendingResetEmail);

      await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);

      Navigator.pop(context);

      FlushbarHelperTest.showSuccess(
        context: context,
        message: '${AppStrings.resetLinkSent}$cleanEmail',
      );

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          RouteHelper.navigateTo(LoginView()),
              (Route<dynamic> route) => false,
        );
      });

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      switch (e.code) {
        case 'user-not-found':
          _setError(AppStrings.emailNotFound);
          FlushbarHelperTest.showError(
            context: context,
            message: AppStrings.noAccountFound,
          );
          break;
        case 'invalid-email':
          _setError(AppStrings.invalidEmail);
          FlushbarHelperTest.showError(
            context: context,
            message: AppStrings.enterValidEmail,
          );
          break;
        default:
          _setError(AppStrings.passwordResetFailed);
          FlushbarHelperTest.showError(
            context: context,
            message: e.message ?? AppStrings.failedToSendReset,
          );
      }
    } catch (e) {
      Navigator.pop(context);
      _setError(AppStrings.passwordResetFailed);
      FlushbarHelperTest.showError(
        context: context,
        message: '${AppStrings.failedToReset}${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }
  Future<void> refreshToken(BuildContext context) async {
    try {
      _setLoading(true);
      final result = await _repository.refreshAuthToken();

      result.fold(
            (error) {
          _setError(error);
          FlushbarHelperTest.showError(context: context, message: error);
        },
            (token) {
          FlushbarHelperTest.showSuccess(
            context: context,
            message: AppStrings.tokenRefreshedSuccessfully,
          );
        },
      );
    } catch (e) {
      _setError(AppStrings.tokenRefreshError);
      FlushbarHelperTest.showError(
        context: context,
        message: '${AppStrings.failedToRefreshToken}${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, AppStrings.signingIn);
      final result = await _repository.signInWithGoogle();
      Navigator.pop(context);
      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelperTest.showError(context: context, message: error);
        },
            (user) async {
          _setUser(user);
          final verificationResult = await _repository.checkEmailVerification();

          verificationResult.fold(
                (error) => FlushbarHelperTest.showError(context: context, message: error),
                (verified) {
              _isEmailVerified = verified;
              FlushbarHelperTest.showSuccess(
                context: context,
                message: AppStrings.googleSignInSuccess,
              );
              notifyListeners();
            },
          );
        },
      );
    } catch (e) {
      _setError(AppStrings.googleSignInFailed);
      FlushbarHelperTest.showError(
        context: context,
        message: '${AppStrings.failedGoogleSignIn}${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, AppStrings.loggingOut);

      final result = await _repository.signOut();
      FlushbarHelper.createSuccess(message: 'successfully sign out').show(context);

      result.fold(
            (error) {
          _setError(error);
        },
            (_) {
          _setUser(null);
          _isEmailVerified = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError(AppStrings.signOutFailed);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

}
