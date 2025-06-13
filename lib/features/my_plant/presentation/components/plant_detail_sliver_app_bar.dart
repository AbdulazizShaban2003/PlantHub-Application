import 'dart:io';
import 'package:flutter/material.dart';

class PlantDetailSliverAppBar extends StatelessWidget {
  final String plantName;
  final List<String> allImages;
  final VoidCallback onEditPressed;
  final VoidCallback onDeleteSelected;

  const PlantDetailSliverAppBar({
    super.key,
    required this.plantName,
    required this.allImages,
    required this.onEditPressed,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          plantName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: _buildImageGallery(),
      ),
      actions: [
        IconButton(
          onPressed: onEditPressed,
          icon: const Icon(Icons.edit),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDeleteSelected();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Plant', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    if (allImages.isEmpty) {
      return Container(
        color: Colors.green.withOpacity(0.1),
        child: const Center(
          child: Icon(
            Icons.eco,
            size: 80,
            color: Colors.green,
          ),
        ),
      );
    }

    return PageView.builder(
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        final imagePath = allImages[index];
        return Container(
          decoration: BoxDecoration(
            image: File(imagePath).existsSync()
                ? DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: !File(imagePath).existsSync()
              ? Container(
            color: Colors.green.withOpacity(0.1),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.grey,
              ),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}