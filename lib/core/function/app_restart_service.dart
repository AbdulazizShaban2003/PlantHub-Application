import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class AppRestartService {
  static Future<void> showRestartDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text('The app needs to restart to apply changes'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartApp(context); // استدعاء دالة إعادة التشغيل
              },
              child: const Text('Restart Now'),
            ),
          ],
        );
      },
    );
  }

  static void _restartApp(BuildContext context) {
    Phoenix.rebirth(context);
  }

  static void quickRestart(BuildContext context) {
    Phoenix.rebirth(context);
  }
}