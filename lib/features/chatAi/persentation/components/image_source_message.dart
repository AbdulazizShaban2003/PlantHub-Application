import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../manager/chat_provider.dart';

class ImageSourceMessage extends StatelessWidget {
  const ImageSourceMessage({
    super.key, required this.provider,
  });
  final ChatProvider provider;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ImageSource>(
      enabled: !provider.isLoading && !provider.isListening,
      icon: Container(
        padding: EdgeInsets.all(SizeConfig().width(0.02)),
        decoration: BoxDecoration(
          color: ColorsManager.greyColor.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add_a_photo,
          color: (provider.isLoading || provider.isListening)
              ? ColorsManager.greyColor.shade400
              : ColorsManager.greyColor,
          size: SizeConfig().responsiveFont(20),
        ),
      ),
      onSelected: (source) => provider.pickImage(source),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ImageSource.camera,
          child: Row(
            children: [
              Icon(Icons.camera_alt, size: SizeConfig().responsiveFont(18),color: ColorsManager.blackColor,),
              SizedBox(width: SizeConfig().width(0.02)),
              Text('Camera', style: TextStyle(fontSize: SizeConfig().responsiveFont(14),color: ColorsManager.blackColor,)),
            ],
          ),
        ),
        PopupMenuItem(
          value: ImageSource.gallery,
          child: Row(
            children: [
              Icon(Icons.photo_library, size: SizeConfig().responsiveFont(18),color: ColorsManager.blackColor,),
              SizedBox(width: SizeConfig().width(0.02)),
              Text('Gallery', style: TextStyle(fontSize: SizeConfig().responsiveFont(14),color: ColorsManager.blackColor,)),
            ],
          ),
        ),
      ],
    );
  }
}