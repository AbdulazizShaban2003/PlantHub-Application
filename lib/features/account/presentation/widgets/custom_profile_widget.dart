import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/features/account/presentation/views/profile_view.dart';

class CustomHeaderProfileWidget extends StatelessWidget {
  const CustomHeaderProfileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig().height(0.04)),
        Center(child: Text(tr('account'), style: Theme.of(context).textTheme.headlineMedium),
        ),
        SizedBox(height: SizeConfig().height(0.05)),

        GestureDetector(
          onTap: (){
            Navigator.push(context, RouteHelper.navigateTo(const ProfileView()));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,


            children: [
              SizedBox(width: 20,),
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
                ),
              ),
              SizedBox(width: 15),
              Column(
                children: [
                  Text(
                    'abdulaziz shaban',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'mail@gmail.com',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                ],
              ),
              Spacer(),
            Icon(Icons.arrow_forward_ios ,size: 16,
              color: Theme.of(context).disabledColor,),
              SizedBox(width: SizeConfig().width(0.07)),
            ],
          ),
        ),
        SizedBox(height: SizeConfig().height(0.02)),
        Divider(),
        SizedBox(height: SizeConfig().height(0.02)),
      ],
    );
  }
}
