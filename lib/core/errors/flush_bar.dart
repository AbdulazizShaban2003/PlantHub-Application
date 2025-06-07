import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_hub_app/core/function/flush_bar_fun.dart';
import 'exceptions.dart';
import 'failure_auth.dart';

Future<void> handleError(
    Object error,
    BuildContext context,
    [StackTrace? stackTrace]
    ) async {
  String message;

  if (error is FailureAuth) {
    message = error.message ?? 'An authentication error occurred';
  }
  else if (error is FirebaseAuthException) {
    message = FirebaseErrors.authErrors[error.code] ??
        error.message ??
        'Authentication failed';
  }
  else if (error is FirebaseException) {
    message = FirebaseErrors.firestoreErrors[error.code] ??
        error.message ??
        'Database operation failed';
  }
  else if (error is SocketException) {
    message = 'No internet connection';
  }
  else if (error is TimeoutException) {
    message = 'Request timed out. Please try again';
  }
  else if (error is PlatformException) {
    message = 'Platform error: ${error.message}';
  }
  else if (error is CustomException) {
    message = error.message;
  }
  else {
    message = 'An unexpected error occurred';
  }

  FlushbarHelper.showError(context: context, message: message);

  // Optionally log the error for debugging
  debugPrint('Error: $error');
  if (stackTrace != null) {
    debugPrint('Stack trace: $stackTrace');
  }
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