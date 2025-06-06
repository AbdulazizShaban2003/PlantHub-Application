
import 'package:flutter/material.dart';

import '../cache/cache_network_image.dart';
import '../utils/size_config.dart';

void showFullScreenImage(
    {required BuildContext context, required String imageUrl, required double heightSize}) {

  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          child: CacheNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: SizeConfig().height(heightSize)
          ),
        ),
      ),
    ),
  );
}
