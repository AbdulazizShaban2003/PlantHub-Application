import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final File? image;
  final String date;
  final bool isTyping;


  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    this.image,
    required this.date,  this.isTyping=false,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xff3AAE72) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(30),
          bottomLeft: isUser ? const Radius.circular(30) : Radius.zero,
          topRight: const Radius.circular(30),
          bottomRight: isUser ? Radius.zero : const Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Image.file(image!, fit: BoxFit.cover),
            ),
          isTyping ? SpinKitThreeBounce(
            color: Colors.black,
            size: 15.0,
          ):
          Text(
            message,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontSize: 10,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
