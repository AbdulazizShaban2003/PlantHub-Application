import 'dart:io';
import 'package:flutter/material.dart';

class ImageFullScreenViewer extends StatelessWidget {
  final String imagePath;

  const ImageFullScreenViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Hero(
          tag: 'image_fullscreen', // Ensure this tag is unique if used elsewhere
          child: InteractiveViewer(
            child: File(imagePath).existsSync()
                ? Image.file(File(imagePath))
                : const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}