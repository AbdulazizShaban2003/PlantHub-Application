import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/size_config.dart';

void showFullImage(BuildContext context, File imageFile) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: SizeConfig().height(0.05),
            right: SizeConfig().width(0.05),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
                size: SizeConfig().responsiveFont(24),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
