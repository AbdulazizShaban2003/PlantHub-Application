import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/utils/size_config.dart';
import 'app_colors.dart' show ColorsManager;

class StylesManager {
  static TextStyle titleMedium = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font24blackbold = TextStyle(
    color: ColorsManager.blackColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font15black = TextStyle(
    color: ColorsManager.blackColor,
    fontSize: 15,
  );
  static TextStyle font16black38 = TextStyle(
    color: ColorsManager.black38Color,
    fontSize: 16,
  );
  static TextStyle font20whitebold = TextStyle(
    color: ColorsManager.whiteColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font18primrypurple = TextStyle(
    color: ColorsManager.purple70color,
    fontSize: 18,
  );
  static TextStyle font20 = TextStyle(fontSize: 20);
  static TextStyle font28whitebold = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle font18boldbrown = TextStyle(
    color: Colors.brown,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle font20black = TextStyle(fontSize: 20, color: Colors.black);
  static TextStyle font22black38 = TextStyle(
    color: ColorsManager.black38Color,
    fontSize: 22,
  );
  static TextStyle font16brown = TextStyle(color: Colors.brown, fontSize: 16);

  static TextStyle fontred16 = TextStyle(
    color: ColorsManager.redColor,
    fontSize: 16,
  );
  static TextStyle font23bold = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font23w700 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 23,
  );
  static TextStyle font22boldBalck = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Colors.black,
  );
  static TextStyle font35bold = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font23brown = TextStyle(color: Colors.brown, fontSize: 23);
  static TextStyle font50 = TextStyle(fontSize: 50);
  //**********************************************************************************************
  static TextStyle font35whiteBold = TextStyle(
    fontSize: SizeConfig().responsiveFont(35),
    color: ColorsManager.whiteColor,
    fontWeight: FontWeight.bold,
  );
  static TextStyle font33blackBold = TextStyle(
  color: ColorsManager.blackColor,
  fontSize: SizeConfig().responsiveFont(25),
  fontWeight: FontWeight.bold,
  );
  static TextStyle font18 = TextStyle(fontSize: SizeConfig().responsiveFont(18),);
  static TextStyle font30Bold = TextStyle(fontSize: SizeConfig().responsiveFont(30),fontWeight: FontWeight.bold);
  static TextStyle font17greyColor = TextStyle(fontSize: SizeConfig().responsiveFont(15),);
  static TextStyle font30bold = TextStyle(fontSize: SizeConfig().responsiveFont(30), fontWeight: FontWeight.bold);



}
