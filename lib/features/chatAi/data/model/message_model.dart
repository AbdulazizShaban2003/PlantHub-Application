import 'dart:io';

class Message {
  final bool isUser;
  final String message;
  final File? image;
  final DateTime date;
  final bool isTyping;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
    this.image,
    this.isTyping = false,
  });
}