import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/account/presentation/views/account_view.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/views/common_diseases_view.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/views/history_screen.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/widgets/common_diseases_section.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/domain/repositories/plant_repo.dart';
import '../../../articles/view_model.dart';
import '../../../diagnosis/presentation/views/diagnosis_screen.dart';
import '../../../diagnosis/presentation/views/disease_category_screen.dart' show DiagnosisSuccessScreen;
import '../../../my_plant/presentation/views/my_plant_view.dart';
import '../../../my_plant/services/firebase_service_notification.dart';
import '../widgets/hom_view_body.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_hub_app/features/account/presentation/views/account_view.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/views/common_diseases_view.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/views/history_screen.dart';
import 'package:plant_hub_app/features/diagnosis/presentation/widgets/common_diseases_section.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import '../../../articles/domain/repositories/plant_repo.dart';
import '../../../articles/view_model.dart';
import '../../../diagnosis/presentation/views/diagnosis_screen.dart';
import '../../../diagnosis/presentation/views/camera_screen.dart';
import '../../../my_plant/presentation/views/my_plant_view.dart';
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
    const DiagnosisScreen(),
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

  // Function to open camera for diagnosis
  Future<void> _openCameraForDiagnosis() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar('No cameras available on this device');
        return;
      }

      // Navigate to camera screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: cameras),
        ),
      );

      // If diagnosis was successful, show success screen
      if (result == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error accessing camera: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: _openCameraForDiagnosis, // Updated to call camera function
        backgroundColor: Color(0xFF00A67E),
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
            color: isSelected
                ? ColorsManager.greenPrimaryColor
                : ColorsManager.greyColor,
            size: SizeConfig().responsiveFont(28),
          ),
          SizedBox(height: SizeConfig().height(0.005)),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig().responsiveFont(10),
              color: isSelected
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

