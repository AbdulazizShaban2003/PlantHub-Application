import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/features/home/presentation/views/bookMark.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../components/build_circle_icon.dart';

class CustomAppBarHomeView extends StatelessWidget implements PreferredSizeWidget  {
  const CustomAppBarHomeView({
    super.key,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AppBar(
        title: Text(
          AppKeyStringTr.nameApp,
          style:Theme.of(context).textTheme.bodyLarge
        ),
        actions: [
          BuildCircleIcon(
            showBadge: true, iconData: CupertinoIcons.bell, onPressed: () {  },
          ),
          SizedBox(width: SizeConfig().width(0.04)),
          BuildCircleIcon(
            onPressed: () {
              Navigator.push(context, RouteHelper.navigateTo(BookmarkedArticlesPage()));
            },
            showBadge: false,
              iconData: CupertinoIcons.bookmark,

          ),
          SizedBox(width: SizeConfig().width(0.02)),
        ],
        leading: Padding(
          padding:  EdgeInsets.only(left: SizeConfig().width(0.04)),
          child: CircleAvatar(
            child: Image(image: AssetImage('assets/images/Image.png')),
          ),
        ),
      ),
    );
  }


}
