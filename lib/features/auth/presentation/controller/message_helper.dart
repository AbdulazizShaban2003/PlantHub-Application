import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class MessageHelper {
  static Future<void> showDelayedSuccess({
    required BuildContext context,
    required String message,
    int delayMilliseconds = 500,
    int durationSeconds = 3,
  }) async {
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
    
    await Flushbar(
      message: message,
      backgroundColor: Colors.green,
      duration: Duration(seconds: durationSeconds),
      leftBarIndicatorColor: Colors.green[700],
      icon: Icon(Icons.check_circle, color: Colors.white),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 300),
    ).show(context);
  }

  // إظهار رسالة خطأ مع تأخير
  static Future<void> showDelayedError({
    required BuildContext context,
    required String message,
    int delayMilliseconds = 500,
    int durationSeconds = 4,
  }) async {
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
    
    await Flushbar(
      message: message,
      backgroundColor: Colors.red,
      duration: Duration(seconds: durationSeconds),
      leftBarIndicatorColor: Colors.red[700],
      icon: Icon(Icons.error, color: Colors.white),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 300),
    ).show(context);
  }

  // إظهار رسالة معلومات مع تأخير
  static Future<void> showDelayedInfo({
    required BuildContext context,
    required String message,
    int delayMilliseconds = 500,
    int durationSeconds = 3,
  }) async {
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
    
    await Flushbar(
      message: message,
      backgroundColor: Colors.blue,
      duration: Duration(seconds: durationSeconds),
      leftBarIndicatorColor: Colors.blue[700],
      icon: Icon(Icons.info, color: Colors.white),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 300),
    ).show(context);
  }

  // إظهار رسالة تحذير مع تأخير
  static Future<void> showDelayedWarning({
    required BuildContext context,
    required String message,
    int delayMilliseconds = 500,
    int durationSeconds = 3,
  }) async {
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
    
    await Flushbar(
      message: message,
      backgroundColor: Colors.orange,
      duration: Duration(seconds: durationSeconds),
      leftBarIndicatorColor: Colors.orange[700],
      icon: Icon(Icons.warning, color: Colors.white),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 300),
    ).show(context);
  }

  // إظهار سلسلة من الرسائل بتأخير
  static Future<void> showSequentialMessages({
    required BuildContext context,
    required List<MessageData> messages,
  }) async {
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      
      switch (message.type) {
        case MessageType.success:
          await showDelayedSuccess(
            context: context,
            message: message.text,
            delayMilliseconds: message.delay,
            durationSeconds: message.duration,
          );
          break;
        case MessageType.error:
          await showDelayedError(
            context: context,
            message: message.text,
            delayMilliseconds: message.delay,
            durationSeconds: message.duration,
          );
          break;
        case MessageType.info:
          await showDelayedInfo(
            context: context,
            message: message.text,
            delayMilliseconds: message.delay,
            durationSeconds: message.duration,
          );
          break;
        case MessageType.warning:
          await showDelayedWarning(
            context: context,
            message: message.text,
            delayMilliseconds: message.delay,
            durationSeconds: message.duration,
          );
          break;
      }
      
      // انتظار بين الرسائل
      if (i < messages.length - 1) {
        await Future.delayed(Duration(milliseconds: message.duration * 1000 + 500));
      }
    }
  }
}

enum MessageType { success, error, info, warning }

class MessageData {
  final String text;
  final MessageType type;
  final int delay;
  final int duration;

  MessageData({
    required this.text,
    required this.type,
    this.delay = 500,
    this.duration = 3,
  });
}
