import 'package:another_flushbar/flushbar.dart' show Flushbar, FlushbarPosition, FlushbarStyle;
import 'package:flutter/material.dart';
class FlushbarHelperTest {
  static void showSuccess({
    required BuildContext context,
    required String message,
    int duration = 3,
  }) {
    showFlushBar(
      context,
      message: message,
      icon: Icon(Icons.check_circle, color: Colors.white),
      backgroundColor: Colors.green,
      duration: duration,
    );
  }static void showError({
    required BuildContext context,
    required String message,
    int duration = 3,
  }) {
    showFlushBar(
      context,
      message: message,
      icon: Icon(Icons.error, color: Colors.white),
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    int duration = 3,
  }) {
    showFlushBar(
      context,
      message: message,
      icon: Icon(Icons.warning, color: Colors.white),
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  // عرض رسالة معلومات
  static void showInfo({
    required BuildContext context,
    required String message,
    int duration = 3,
  }) {
    showFlushBar(
      context,
      message: message,
      icon: Icon(Icons.info, color: Colors.white),
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  static void showFlushBar(
      BuildContext context, {
        required String message,
        required Icon icon,
        required Color backgroundColor,
        int duration = 3,
      }) {
    Flushbar(
      message: message,
      icon: icon,
      shouldIconPulse: false,
      duration: Duration(seconds: duration),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: backgroundColor,
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 2),
          blurRadius: 3.0,
        )
      ],
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      isDismissible: true,
    ).show(context);
  }
}