import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../controller/full_Image_controller.dart';

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final File? image;
  final String date;
  final bool isTyping;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    this.image,
    required this.date,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: SizeConfig().width(0.75)),
        padding: EdgeInsets.all(SizeConfig().width(0.03)),
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig().height(0.005),
          horizontal: SizeConfig().width(0.02),
        ),
        decoration: BoxDecoration(
          color:
              isUser
                  ? ColorsManager.greenPrimaryColor
                  : ColorsManager.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeConfig().width(0.05)),
            topRight: Radius.circular(SizeConfig().width(0.05)),
            bottomLeft:
                isUser
                    ? Radius.circular(SizeConfig().width(0.05))
                    : Radius.circular(SizeConfig().width(0.01)),
            bottomRight:
                isUser
                    ? Radius.circular(SizeConfig().width(0.01))
                    : Radius.circular(SizeConfig().width(0.05)),
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.blackColor.withOpacity(0.1),
              blurRadius: SizeConfig().width(0.02),
              offset: Offset(0, SizeConfig().height(0.0025)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null) ...[
              GestureDetector(
                onTap: () => showFullImage(context, image!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SizeConfig().width(0.02)),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: SizeConfig().height(0.15),
                      maxWidth: SizeConfig().width(0.3),
                    ),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: SizeConfig().height(0.1),
                          width: SizeConfig().width(0.2),
                          color: ColorsManager.greyColor.shade300,
                          child: Icon(
                            Icons.broken_image,
                            color: ColorsManager.greyColor,
                            size: SizeConfig().responsiveFont(20),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (message.isNotEmpty)
                SizedBox(height: SizeConfig().height(0.01)),
            ],
            if (isTyping)
              SpinKitThreeBounce(
                color: ColorsManager.greyColor,
                size: SizeConfig().responsiveFont(20),
              )
            else if (message.isNotEmpty)
              SelectableText(
                message,
                style: TextStyle(
                  color:
                      isUser
                          ? ColorsManager.whiteColor
                          : ColorsManager.blackColor,
                  fontSize: SizeConfig().responsiveFont(14),
                  height: 1.4,
                ),
              ),

            if (!isTyping) ...[
              SizedBox(height: SizeConfig().height(0.005)),
              Text(
                date,
                style: TextStyle(
                  color:
                      isUser
                          ? ColorsManager.white70Color
                          : ColorsManager.greyColor.shade600,
                  fontSize: SizeConfig().responsiveFont(11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
