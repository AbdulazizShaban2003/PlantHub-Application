import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/account/presentation/views/account_view.dart';
import 'package:plant_hub_app/features/my_plant/screens/my_plant_view.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/domain/repositories/plant_repo.dart';
import '../../../articles/view_model.dart';
import '../../../my_plant/services/firebase_service_notification.dart';
import '../widgets/hom_view_body.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> screens = [
    const HomeViewBody(),
    const Placeholder(),
    FutureBuilder(
      future: FirebaseServiceNotify().signInAnonymously(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MyPlantView();
      },
    ),
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      extendBody: true,
      body: Center(child: screens[_selectedIndex]),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: SizeConfig().width(0.02),
        child: SizedBox(
          height: SizeConfig().height(0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig().width(0.05)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(CupertinoIcons.home, AppKeyStringTr.home, 0),
                _buildNavItem(
                  CupertinoIcons.shield,
                  AppKeyStringTr.diagnose,
                  1,
                ),
                SizedBox(width: SizeConfig().width(0.02)),
                _buildNavItem(
                  CupertinoIcons.leaf_arrow_circlepath,
                  AppKeyStringTr.myPlant,
                  2,
                ),
                _buildNavItem(CupertinoIcons.person, AppKeyStringTr.account, 3),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ColorsManager.greenPrimaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(
          CupertinoIcons.camera,
          color: ColorsManager.whiteColor,
          size: SizeConfig().responsiveFont(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? ColorsManager.greenPrimaryColor
                    : ColorsManager.greyColor,
            size: SizeConfig().responsiveFont(28),
          ),
          SizedBox(height: SizeConfig().height(0.005)),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(10),
              color:
                  isSelected
                      ? ColorsManager.greenPrimaryColor
                      : ColorsManager.greyColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
