import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/auth/data/models/user_model.dart';
import 'package:plant_hub_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/function/flush_bar_fun.dart';
import '../controller/operation_controller.dart';

class AuthProviderManager with ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  bool _isEmailVerified = false;
  final OperationController operationController;

  AuthProviderManager({required AuthRepository repository,    required this.operationController,
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
        FlushbarHelper.showError(context: context, message: error);
      },
          (verified) {
        _isEmailVerified = verified;
        if (verified) {
          FlushbarHelper.showSuccess(
            context: context,
            message: 'Email verified successfully!',
          );
        } else {
          FlushbarHelper.showInfo(
            context: context,
            message: 'Email not yet verified',
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
        FlushbarHelper.showError(context: context, message: error);
      },
          (_) {
        FlushbarHelper.showSuccess(
          context: context,
          message: 'Verification email resent successfully',
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
      operationController.showLoadingDialog(context, 'Signing up...');
      final result = await _repository.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
Navigator.pop(context);
      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelper.showError(context: context, message: error);
        },
            (user) async {
          _setUser(user);
          final verificationResult = await _repository.sendEmailVerification();
          verificationResult.fold(
                (error) => FlushbarHelper.showError(context: context, message: error),
                (_) => FlushbarHelper.showSuccess(
              context: context,
              message: 'Verification email sent. Please check your inbox.',
            ),
          );
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred');
      FlushbarHelper.showError(
        context: context,
        message: 'Failed to create account: ${e.toString()}',
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
      operationController.showLoadingDialog(context, 'Log in...');


      final result = await _repository.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pop(context);

      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelper.showError(context: context, message: error);
        },
            (user) async {
          _setUser(user);
          final verificationResult = await _repository.checkEmailVerification();

          verificationResult.fold(
                (error) => FlushbarHelper.showError(context: context, message: error),
                (verified) {
              _isEmailVerified = verified;
              if (verified) {
                FlushbarHelper.showSuccess(
                  context: context,
                  message: 'Logged in successfully!',
                );
              } else {
                _repository.sendEmailVerification();
                FlushbarHelper.showWarning(
                  context: context,
                  message: 'Please verify your email first. Verification email sent.',
                );
              }
              notifyListeners();
            },
          );
        },
      );
    } catch (e) {
      _setError('Login failed');
      FlushbarHelper.showError(
        context: context,
        message: 'Failed to login: ${e.toString()}',
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
      operationController.showLoadingDialog(context, 'Sent link...');

      final result = await _repository.sendPasswordResetEmail(email);
      Navigator.pop(context);

      result.fold(
            (error) {
          _setError(error);
          FlushbarHelper.showError(context: context, message: error);
        },
            (_) {
          FlushbarHelper.showSuccess(
            context: context,
            message: 'Password reset link sent to your email',
          );
        },
      );
    } catch (e) {
      _setError('Password reset failed');
      FlushbarHelper.showError(
        context: context,
        message: 'Failed to send password reset: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      _setError(null);
      operationController.showLoadingDialog(context, 'Signing ...');
      final result = await _repository.signInWithGoogle();
      Navigator.pop(context);

      await result.fold(
            (error) async {
          _setError(error);
          FlushbarHelper.showError(context: context, message: error);
        },
            (user) async {
          _setUser(user);
          final verificationResult = await _repository.checkEmailVerification();

          verificationResult.fold(
                (error) => FlushbarHelper.showError(context: context, message: error),
                (verified) {
              _isEmailVerified = verified;
              FlushbarHelper.showSuccess(
                context: context,
                message: 'Signed in with Google successfully!',
              );
              notifyListeners();
            },
          );
        },
      );
    } catch (e) {
      _setError('Google sign-in failed');
      FlushbarHelper.showError(
        context: context,
        message: 'Failed to sign in with Google: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _repository.signOut();

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
      _setError('Sign out failed');
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