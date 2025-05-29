import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../config/theme/app_colors.dart';

class OperationController{
  Future<void> showErrorDialog(String message,BuildContext context) async{
   await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 300,
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 80),
                const SizedBox(height: 10),
                const Text(
                  'Error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: ColorsManager.blackColor),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 14, color: ColorsManager.blackColor
                ),),
                const SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: ColorsManager.greenPrimaryColor,
                    foregroundColor: ColorsManager.whiteColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showLoadingDialog(BuildContext context, String message) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 300,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitRing(color: ColorsManager.greenPrimaryColor),
                const SizedBox(height: 20),
                Text(message, style: const TextStyle(fontSize: 16,color: ColorsManager.blackColor), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showSuccessDialog(String message, BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 300,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: ColorsManager.greenPrimaryColor, size: 80),
                const SizedBox(height: 10),
                const Text(
                  'Success',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: ColorsManager.whiteColor),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 14, color: ColorsManager.blackColor
                ),),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

}