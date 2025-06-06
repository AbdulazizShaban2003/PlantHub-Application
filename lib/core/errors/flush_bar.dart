import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_hub_app/core/function/flush_bar_fun.dart';
import 'package:plant_hub_app/features/auth/presentation/controller/operation_controller.dart';

import '../../features/auth/presentation/views/forget_password_view.dart';
import 'failure_auth.dart';

Future<void> handleError(
    Object error,
    BuildContext context,
    [StackTrace? stackTrace]
    ) async {
  String message;
  String errorCode = 'unknown-error';

  if (error is FailureAuth) {
    message = error.message;
    errorCode = error.message ?? 'custom-error';
  }
  else if (error is FirebaseAuthException) {
    message = _getFirebaseAuthErrorMessage(error);
    errorCode = error.code;
  }
  else if (error is FirebaseException) {
    message = 'Database error: ${error.message}';
    errorCode = error.code;
  }
  else if (error is SocketException) {
    message = 'No internet connection';
    errorCode = 'network-error';
  }
  else if (error is TimeoutException) {
    message = 'Request timed out. Please try again';
    errorCode = 'timeout';
  }
  else if (error is PlatformException) {
    message = 'Platform error: ${error.message}';
    errorCode = error.code;
  }
  else {
    message = 'An unexpected error occurred';
    errorCode = 'unknown-error';
  }

FlushbarHelper.showError(context: context, message: message);
}

String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'The email address is already in use';
    case 'invalid-email':
      return 'The email address is invalid';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled';
    case 'weak-password':
      return 'The password is too weak';
    case 'user-disabled':
      return 'This user account has been disabled';
    case 'user-not-found':
      return 'No user found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'too-many-requests':
      return 'Too many requests. Please try again later';
    default:
      return e.message ?? 'Authentication failed';
  }
}