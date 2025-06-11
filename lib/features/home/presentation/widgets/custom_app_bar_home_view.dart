import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/bookMark/presentation/views/bookmark_view.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../account/presentation/manager/profile_provider.dart';
import '../../../account/presentation/views/profile_view.dart';
import '../../../articles/view_model.dart';
import '../../../my_plant/providers/plant_provider.dart';
import '../views/notifications_screen.dart';
import '../components/build_circle_icon.dart';

class CustomAppBarHomeView extends StatelessWidget implements PreferredSizeWidget  {
  const CustomAppBarHomeView({
    super.key, required this.plantProvider,
  });
  final PlantViewModel plantProvider;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppBar(
        title: Text(
          AppKeyStringTr.nameApp,
          style:Theme.of(context).textTheme.bodyLarge
        ),

        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Stack(
            children: [
              BuildCircleIcon(
                iconData: CupertinoIcons.bell, onPressed: () {
                Navigator.push(context, RouteHelper.navigateTo(NotificationsView()));
              },
                showBadge: false,
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  final unreadCount = provider.unreadCount;
                  if (unreadCount > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig().width(0.007)),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                              SizeConfig().width(0.04)
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: SizeConfig().width(0.03),
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig().responsiveFont(6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          SizedBox(width: SizeConfig().width(0.04)),
          BuildCircleIcon(
            onPressed: () {
              Navigator.push(context, RouteHelper.navigateTo(BookmarkView(plantProvider: plantProvider)));
            },
            showBadge: false,
              iconData: CupertinoIcons.bookmark,
          ),
          SizedBox(width: SizeConfig().width(0.02)),


        ],
        leading: Padding(
          padding:  EdgeInsets.only(left: SizeConfig().width(0.04)),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, RouteHelper.navigateTo(const ProfileView()));
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                image: provider.profileImagePath != null
                    ? DecorationImage(
                  image: FileImage(
                    File(provider.profileImagePath!),
                  ),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }


}
