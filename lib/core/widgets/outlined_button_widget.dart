import 'package:flutter/material.dart';
class OutlinedButtonWidget extends StatelessWidget {
   OutlinedButtonWidget({
    super.key,
    required this.nameButton, required this.onPressed, this.foregroundColor,   this.backgroundColor,
     this.style
  });

  final String nameButton;
  final VoidCallback onPressed;
  Color? foregroundColor;
  Color ?backgroundColor;
  TextStyle? style;


  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
      onPressed: onPressed,
      child: Text(nameButton,style: style)
    );
  }
}
