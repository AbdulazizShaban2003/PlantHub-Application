import 'package:flutter/material.dart';

class SizeConfig {
  static final SizeConfig _instance = SizeConfig._internal();

  late MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;
  late double _devicePixelRatio;
  late double _textScaleFactor;

  factory SizeConfig() {
    return _instance;
  }

  SizeConfig._internal();

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _devicePixelRatio = _mediaQueryData.devicePixelRatio;
    _textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  double width(double inputWidth) => _screenWidth * inputWidth;

  double height(double inputHeight) => _screenHeight * inputHeight;

  double responsiveFont(double fontSize) {
    final scaleFactor = _getScaleFactor();
    final baseSize = fontSize * scaleFactor / _textScaleFactor;
    return baseSize.clamp(fontSize * 0.85, fontSize * 1.25);
  }

  double _getScaleFactor() {
    if (_screenWidth < 600) return _screenWidth / 400;
    if (_screenWidth < 900) return _screenWidth / 700;
    return _screenWidth / 1200;
  }
}