import 'package:flutter/material.dart';

import '../../core/utils/size_config.dart';
import 'app_colors.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xDD000000),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
      color: Colors.grey.shade400,
      fontSize: 13,
    ),

      contentPadding: EdgeInsets.symmetric(
        vertical: SizeConfig().height(0.0012),
        horizontal: SizeConfig().width(0.01),
      ),
      prefixIconColor: Colors.grey.shade400,

    ),
    dialogTheme:  DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      contentTextStyle: TextStyle(color: Colors.black54),
    ),
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorsManager.whiteColor,
        backgroundColor: ColorsManager.greenPrimaryColor,
        side: BorderSide.none,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      dialHandColor: Colors.green[100],
      dialBackgroundColor: Colors.white,
      entryModeIconColor: Colors.green[100],
      hourMinuteTextColor: Colors.black,

      dayPeriodTextStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),

      dayPeriodColor: Colors.grey[100],

      hourMinuteColor: MaterialStateColor.resolveWith((states) =>
      states.contains(MaterialState.selected)
          ? Colors.green[100]!
          : Colors.white,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),

      hourMinuteTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),

      dialTextColor: Colors.black,

      helpTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),

    dividerTheme: DividerThemeData(
      thickness: SizeConfig().height(0.001),
       color:  Color(0x1F000000).withOpacity(0.2)
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorsManager.blackColor,
        backgroundColor: ColorsManager.greyColor.shade200,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorsManager.blackColor,
        backgroundColor: ColorsManager.whiteColor.withOpacity(0.8),
        side: BorderSide.none,
        elevation: 3,
        minimumSize: const Size(double.infinity, 50),
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    indicatorColor: ColorsManager.greyColor,
    appBarTheme: AppBarTheme(
      titleSpacing: 10,
      iconTheme: IconThemeData(
        color: ColorsManager.blackColor,

      ),
      foregroundColor: Color(0xFF121212),
      backgroundColor: Color(0xFFFFFFFF),
      centerTitle: true,
      actionsPadding: EdgeInsets.symmetric(horizontal: 5),
      titleTextStyle: TextStyle(color: Colors.black),
    ),
    cardColor: Color(0xFFF5F5F5),
    dividerColor: Color(0x1F000000),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xDD000000),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Color(0xDD000000),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Color(0xDD000000),
        fontWeight: FontWeight.bold, fontSize: 20),
      bodyMedium: TextStyle(color: Color(0xDD000000),fontWeight: FontWeight.bold,fontSize: 16),
      bodySmall: TextStyle(color:  Colors.black,fontWeight: FontWeight.w600),
      labelLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
      ),
      labelSmall: TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        color: Color(0xDD000000),
        fontWeight: FontWeight.bold,
      ),
        titleSmall:TextStyle(color:  Colors.grey),
    ),
    iconTheme: IconThemeData(color: Color(0xFFFFFFFF), size: 20),
    colorScheme: ColorScheme.light(
      primary:  ColorsManager.greenPrimaryColor,
      secondary: Color(0xFF121212),
      error: Color(0xFFFF5252),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F5F5),
      onPrimary: ColorsManager.greenPrimaryColor.withOpacity(0.1,),
      onSecondary: Color(0xFF121212),
      onBackground: Color(0xFF212121),
      onSurface:Colors.grey,
      onError: Color(0xFFFFFFFF),
    ),
  );
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: ColorsManager.whiteColor,


    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 10,
      ),
      filled: true,
      fillColor: Colors.white10.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: SizeConfig().height(0.001),
        horizontal: SizeConfig().width(0.01),
      ),
      prefixIconColor: Colors.grey.shade400,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorsManager.whiteColor,
        backgroundColor: ColorsManager.greenPrimaryColor,
        side: BorderSide.none,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    dividerTheme: DividerThemeData(
        thickness: SizeConfig().height(0.001),
        color:  Colors.white.withOpacity(0.2)
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorsManager.blackColor,
        backgroundColor: ColorsManager.greyColor.shade200,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 40),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorsManager.blackColor,
        backgroundColor: ColorsManager.whiteColor.withOpacity(0.8),
        side: BorderSide.none,
        elevation: 3,
        minimumSize: const Size(double.infinity, 50),
        padding: EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),

    indicatorColor: ColorsManager.greyColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
    datePickerTheme: DatePickerThemeData(

      backgroundColor: Colors.grey[900],
      headerBackgroundColor: ColorsManager.greenPrimaryColor,
      headerForegroundColor: Colors.white,
      todayBorder: BorderSide(color: ColorsManager.greenPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    cardColor: Color(0xFF1E1E1E),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      elevation: 0,
    ),

      dialogTheme: DialogTheme(
        backgroundColor: Colors.grey[900],
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: TextStyle(color: Colors.white70),
      ),

    bottomAppBarTheme: BottomAppBarTheme(color: Colors.black, elevation: 0),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Color(0xDDFFFFFF),fontWeight: FontWeight.bold,fontSize: 20),
      bodyMedium: TextStyle(color: Color(0xDDFFFFFF) ,fontWeight: FontWeight.bold , fontSize: 16),
      bodySmall: TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        color: Color(0xFF1E1E1E),
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(color: Colors.grey.shade600),
      titleSmall: TextStyle(color: Colors.grey.shade600),
    ),
    iconTheme: IconThemeData(color: Color(0xFFFFFFFF), size: 25),
    colorScheme: ColorScheme.dark(
      primary: ColorsManager.greenPrimaryColor,
      secondary: Color(0xFF121212),
      error: Color(0xFFFF5252),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFFE0E0E0),
      onSurface: Color(0xFFE0E0E0),
      onError: Color(0xFFFFFFFF),
    ).copyWith(background: Color(0xFF121212)),
  );
}
