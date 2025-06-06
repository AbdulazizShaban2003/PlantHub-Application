import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../config/theme/app_colors.dart';

class CacheNetworkImage extends StatelessWidget {
  const CacheNetworkImage({
    super.key,
    required this.imageUrl, required this.width, required this.height,
  });

  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: ColorsManager.greyColor[100],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color:  ColorsManager.greyColor[100],
        child:  Icon(Icons.error, color: ColorsManager.redColor),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeIn,
    );
  }
}