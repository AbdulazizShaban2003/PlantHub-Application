import 'dart:io';

class Message {
  final String id;
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTyping;
  final bool hasImage;
  final String? imageId;
  File? _imageFile;

  Message({
    String? id,
    required this.isUser,
    required this.message,
    required this.date,
    this.isTyping = false,
    this.hasImage = false,
    this.imageId,
    File? imageFile,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        _imageFile = imageFile;

  File? get imageFile => _imageFile;

  void setImageFile(File? file) {
    _imageFile = file;
  }

  Message copyWith({
    String? id,
    bool? isUser,
    String? message,
    DateTime? date,
    bool? isTyping,
    bool? hasImage,
    String? imageId,
    File? imageFile,
  }) {
    return Message(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      message: message ?? this.message,
      date: date ?? this.date,
      isTyping: isTyping ?? this.isTyping,
      hasImage: hasImage ?? this.hasImage,
      imageId: imageId ?? this.imageId,
      imageFile: imageFile ?? _imageFile,
    );
  }
}
