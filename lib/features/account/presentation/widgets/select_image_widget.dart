import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../../../../core/utils/asstes_manager.dart';

class SelectedImageWidget extends StatelessWidget {
  const SelectedImageWidget({
    super.key,
    required String? profileImagePath,
    required bool hasPhotoUrl,
  }) : _profileImagePath = profileImagePath, _hasPhotoUrl = hasPhotoUrl;

  final String? _profileImagePath;
  final bool _hasPhotoUrl;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;
    final defaultAvatar = Image.asset(AssetsManager.emptyImage);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: SizeConfig().height(0.12),
          height: SizeConfig().height(0.12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorsManager.greyColor.shade300,
              width: SizeConfig().width(0.003),
            ),
            image: _getProfileImageDecoration(),
          ),
        ),
        if (!_hasPhotoUrl) _buildEditIcon(),
      ],
    );
  }

  DecorationImage? _getProfileImageDecoration() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user?.photoURL != null) {
      return DecorationImage(
        image: NetworkImage(user!.photoURL!),
        fit: BoxFit.cover,
      );
    } else if (_profileImagePath != null) {
      return DecorationImage(
        image: FileImage(File(_profileImagePath!)),
        fit: BoxFit.cover,
      );
    }
    return const DecorationImage(
      image: AssetImage(AssetsManager.emptyImage),
      fit: BoxFit.cover,
    );
  }

  Widget _buildEditIcon() {
    return Container(
      padding: EdgeInsets.all(SizeConfig().width(0.01)),
      decoration: BoxDecoration(
        color: const Color(0xFF00A86B),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: SizeConfig().width(0.005),
        ),
      ),
      child: Icon(
        Icons.edit,
        color: Colors.white,
        size: SizeConfig().responsiveFont(16),
      ),
    );
  }
}