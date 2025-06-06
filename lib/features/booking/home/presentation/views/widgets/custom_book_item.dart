import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';

import '../../../../../../core/cache/cache_network_image.dart';

class CustomBookImage extends StatelessWidget {
  const CustomBookImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CacheNetworkImage(
        imageUrl: imageUrl,
        width: SizeConfig().width(0.62),
        height: SizeConfig().height(0.33),
      ),
    );
  }
}
