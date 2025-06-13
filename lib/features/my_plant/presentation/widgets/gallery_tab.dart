import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/image_full_screen_viewer.dart';
class GalleryTab extends StatelessWidget {
  final List<String> allImages;

  const GalleryTab({super.key, required this.allImages});

  void _showImageFullScreen(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageFullScreenViewer(imagePath: imagePath),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (allImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: SizeConfig().responsiveFont(64), color:ColorsManager.greyColor),
            SizedBox(height: SizeConfig().height(0.02)),
            Text(
              AppStrings.noPhotosYet,
              style: TextStyle(fontSize: SizeConfig().responsiveFont(18), color: ColorsManager.greyColor),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(SizeConfig().width(0.04)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: SizeConfig().width(0.03),
        mainAxisSpacing: SizeConfig().height(0.015),
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        final imagePath = allImages[index];
        return GestureDetector(
          onTap: () => _showImageFullScreen(context, imagePath),
          child: Hero(
            tag: 'image_$index',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig().responsiveFont(12)),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.blackColor.withOpacity(0.1),
                    blurRadius: SizeConfig().responsiveFont(8),
                    offset: Offset(0, SizeConfig().responsiveFont(2)),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig().responsiveFont(12)),
                child: File(imagePath).existsSync()
                    ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: ColorsManager.greyColor[200],
                  child: Icon(
                    Icons.broken_image,
                    size: SizeConfig().responsiveFont(40),
                    color:ColorsManager.greyColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
