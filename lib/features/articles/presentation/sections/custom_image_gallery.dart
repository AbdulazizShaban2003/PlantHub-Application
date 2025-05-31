import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;

  const ImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Text('No images available');
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[index],
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
