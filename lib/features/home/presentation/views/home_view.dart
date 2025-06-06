import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/domain/repositories/plant_repo.dart';
import '../../../articles/view_model.dart';
import '../../../chatAi/controller/chat_provider.dart';
import '../widgets/hom_view_body.dart';
class HomeView extends StatefulWidget {
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
  List<Widget>Screens=[
    HomeViewBody(),

  ];
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      extendBody: true,

      body: Center(child: Screens[_selectedIndex]),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: SizeConfig().height(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.home, AppKeyStringTr.home, 0),
              _buildNavItem(CupertinoIcons.shield, AppKeyStringTr.diagnose, 1),
              SizedBox(width: 40),
              _buildNavItem(CupertinoIcons.leaf_arrow_circlepath, AppKeyStringTr.myPlant, 2),
              _buildNavItem(CupertinoIcons.person, AppKeyStringTr.account, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {},
        backgroundColor: ColorsManager.greenPrimaryColor,
        shape: CircleBorder(),
        child: Icon(CupertinoIcons.camera),
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
        children: [
          Icon(icon, color: isSelected ? ColorsManager.greenPrimaryColor : ColorsManager.greyColor),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? ColorsManager.greenPrimaryColor : ColorsManager.greyColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}