import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/function/image_show_dialog.dart';

import '../../../../core/utils/size_config.dart';


class PlantImage extends StatelessWidget {
  final String imageUrl;

  const PlantImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: (){
          showFullScreenImage(context: context, imageUrl: imageUrl, heightSize: 0.35);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 13 / 9,
            child: CachedNetworkImage(imageUrl: imageUrl,
              width: double.infinity,
              height: SizeConfig().height(0.30),
            )
          ),
        ),
      ),
    );
  }
}
