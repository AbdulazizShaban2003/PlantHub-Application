import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

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
      expandedHeight: SizeConfig().height(0.375),
      pinned: true,
      forceMaterialTransparency: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          plantName,
          style: TextStyle(
            fontSize: SizeConfig().responsiveFont(20),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(
                  SizeConfig().width(0.0025),
                  SizeConfig().width(0.0025),
                ),
                blurRadius: SizeConfig().width(0.0075),
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: _buildImageGallery(context),
      ),
      actions: [
        IconButton(
          onPressed: onEditPressed,
          icon: Icon(Icons.edit, size: SizeConfig().responsiveFont(24)),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDeleteSelected();
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: SizeConfig().responsiveFont(20),
                      ),
                      SizedBox(width: SizeConfig().width(0.02)),
                      Text(
                        'Delete Plant',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: SizeConfig().responsiveFont(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    if (allImages.isEmpty) {
      return Container(
        color: Colors.green.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.eco,
            size: SizeConfig().responsiveFont(80),
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
            image:
                File(imagePath).existsSync()
                    ? DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    )
                    : null,
          ),
          child:
              !File(imagePath).existsSync()
                  ? Container(
                    color: Colors.green.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: SizeConfig().responsiveFont(80),
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
