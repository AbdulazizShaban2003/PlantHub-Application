// lib/features/auth/presentation/providers/password_visibility_provider.dart
import 'package:flutter/material.dart';

class PasswordVisibilityProvider with ChangeNotifier {
  bool _obscureText = true;

  bool get obscureText => _obscureText;

  void toggleVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
}