import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart' show ColorsManager;
class BuildTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? preffixIcon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextEditingController controller;
  const BuildTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.preffixIcon,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary,fontSize: 12),
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        prefixIcon: preffixIcon,
      ),
    );
  }
}
