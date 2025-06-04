import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final String plantId;
  final String imageUrl;
  final String description;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plantId,
    required this.imageUrl,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 18,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}