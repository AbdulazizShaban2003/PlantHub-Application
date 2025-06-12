import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/core/utils/asstes_manager.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import '../views/profile_view.dart';

class CustomHeaderProfileWidget extends StatelessWidget {
  const CustomHeaderProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'abdulaziz shaban';
    final String email = user?.email ?? 'mail@gmail.com';
    final String? photoUrl = user?.photoURL;
    final defaultAvatar = Image.asset(AssetsManager.emptyImage);

    return Column(
      children: [
        SizedBox(height: SizeConfig().height(0.04)),
        Center(
          child: Text(
            'Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: SizeConfig().responsiveFont(22),
            ),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.05)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              RouteHelper.navigateTo(const ProfileView()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().width(0.05),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: SizeConfig().height(0.05),
                  backgroundColor: Colors.transparent,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl) as ImageProvider
                      : defaultAvatar.image,
                ),
                SizedBox(width: SizeConfig().width(0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(16),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeConfig().height(0.005)),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: SizeConfig().responsiveFont(14),
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.greyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: SizeConfig().responsiveFont(16),
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        const Divider(),
        SizedBox(height: SizeConfig().height(0.02)),
      ],
    );
  }
}