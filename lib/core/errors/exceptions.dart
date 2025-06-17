import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../function/flush_bar_fun.dart';

class FirebaseAuthExceptionHandler {
  static String handleException(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'The user account is disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
// firebase_errors.dart

class FirebaseErrors {
  // ==================== Firebase Authentication Errors ====================
  static const Map<String, String> authErrors = {
    'invalid-email': 'Invalid email format. Please enter a valid email.',
    'user-disabled': 'This account has been disabled. Contact support.',
    'user-not-found': 'No account found with this email address.',
    'wrong-password': 'Incorrect password. Please try again.',
    'email-already-in-use': 'This email is already registered.',
    'operation-not-allowed': 'Email/password login is not enabled in Firebase.',
    'weak-password': 'Password is too weak. Use at least 6 characters.',
    'too-many-requests': 'Too many attempts. Please try again later.',
    'invalid-credential': 'Invalid login credentials or token expired.',
    'account-exists-with-different-credential':
        'Account exists with different login method.',
    'network-request-failed': 'Network error. Check your internet connection.',
  };

  // ==================== Firestore Errors ====================
  static const Map<String, String> firestoreErrors = {
    'permission-denied': 'You don\'t have permission to access this data.',
    'not-found': 'Document or collection not found.',
    'already-exists': 'Document already exists.',
    'resource-exhausted': 'Quota exceeded. Try again later.',
    'failed-precondition': 'Operation not allowed in current state.',
    'unavailable': 'Service temporarily unavailable. Try again later.',
    'unauthenticated': 'Authentication required. Please login first.',
  };

  // ==================== FCM Notifications Errors ====================
  static const Map<String, String> notificationErrors = {
    'invalid-argument': 'Invalid notification data.',
    'registration-token-not-registered':
        'Device not registered for notifications.',
    'mismatched-credential': 'FCM credentials don\'t match project.',
    'messaging-service-unavailable': 'Notification service unavailable.',
  };

  // ==================== Error Display Methods ====================

  /// Shows authentication error using Flushbar
  static void showAuthError(BuildContext context, String errorCode) {
    final message =
        authErrors[errorCode] ?? 'Unknown authentication error: $errorCode';
    FlushbarHelperTest.showError(context: context, message: message);
  }

  /// Shows Firestore error using Flushbar
  static void showFirestoreError(BuildContext context, String errorCode) {
    final message = firestoreErrors[errorCode] ?? 'Database error: $errorCode';
    FlushbarHelperTest.showError(context: context, message: message);
  }

  /// Shows notification error using Flushbar
  static void showNotificationError(BuildContext context, String errorCode) {
    final message =
        notificationErrors[errorCode] ?? 'Notification error: $errorCode';
    FlushbarHelperTest.showError(context: context, message: message);
  }

  /// Handles any Firebase exception and shows appropriate error
  static void handleFirebaseError(BuildContext context, dynamic error) {
    if (error is FirebaseAuthException) {
      showAuthError(context, error.code);
    } else if (error is FirebaseException) {
      showFirestoreError(context, error.code);
    } else {
      FlushbarHelperTest.showError(
        context: context,
        message: 'Unexpected error: ${error.toString()}',
      );
    }
  }
}
class CustomException implements Exception {
  final String message;

  CustomException({required this.message});

  @override
  String toString() {
    return message;
  }
}

