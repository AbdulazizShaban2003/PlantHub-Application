import 'package:flutter/material.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../core/cache/cache_network_image.dart';
import '../../../../core/function/image_show_dialog.dart';
import '../../../../core/utils/app_strings.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;

  const ImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return  Center(child: Text(AppStrings.noImageAvil));
    }

    return SizedBox(
      height: SizeConfig().height(0.15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];
          if (imageUrl.isEmpty) return const SizedBox();

          return Padding(
            key: ValueKey(imageUrl),
            padding: EdgeInsets.only(right: SizeConfig().width(0.02)),
            child: GestureDetector(
              onTap: () => showFullScreenImage(context: context, imageUrl: imageUrl, heightSize: 0.3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CacheNetworkImage(
                  imageUrl: imageUrl,
                  width: SizeConfig().width(0.48),
                  height: SizeConfig().height(0.11),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}