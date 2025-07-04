// lib/features/auth/presentation/components/build_Text_field.dart
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

class BuildTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final VoidCallback? onSuffixIconPressed;
  final bool  read;

  const BuildTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.read=false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: obscureText
          ? [AutofillHints.password]
          : [AutofillHints.email],
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondary,
        fontSize: SizeConfig().responsiveFont(14),
      ),
      readOnly: read,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon != null && onSuffixIconPressed != null
            ? IconButton(
          icon: suffixIcon!,
          onPressed: onSuffixIconPressed,
        )
            : suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }
}