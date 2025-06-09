import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../config/theme/app_colors.dart';

class OperationController{
  Future<void> showLoadingDialog(BuildContext context, String message) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: SizeConfig().width(0.35),
          height: SizeConfig().height(0.22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitRing(color: ColorsManager.greenPrimaryColor),
                 SizedBox(height: SizeConfig().height(0.02)),
                Text(message, style:  TextStyle(fontSize: SizeConfig().responsiveFont(15),color: ColorsManager.blackColor,fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}