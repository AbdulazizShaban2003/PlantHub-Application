import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlantImage extends StatelessWidget {
  final String imageUrl;

  const PlantImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error, color: Colors.red),
            ),
            fadeInDuration: const Duration(milliseconds: 300),
            fadeInCurve: Curves.easeIn,
          ),
        ),
      ),
    );
  }
}
