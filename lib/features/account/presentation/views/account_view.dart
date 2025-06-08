import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/core/provider/language_provider.dart';
import 'package:plant_hub_app/features/account/presentation/views/privacy_policy_screen.dart';
import 'package:plant_hub_app/features/account/presentation/views/support_us_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../auth/presentation/manager/auth_provider.dart';
import '../components/build_language_setting_item.dart';
import '../components/build_setting_item_component.dart';
import '../widgets/custom_profile_widget.dart';
import 'notification_settings_screen.dart';
import 'plant_photography_guide_screen.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  bool savePhotoEnabled = false;
  bool notificationAlertsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthProviderManager>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomHeaderProfileWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Consumer<LanguageProvider>(
                          builder: (context, languageProvider, child) {
                            return buildLanguageSettingItem(context, languageProvider);
                          }
                      ),
                      Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return buildSettingItem(
                              context: context,
                              icon: Icons.dark_mode_outlined,
                              title: tr('Dark mode'),
                              hasToggle: true,
                              toggleValue: themeProvider.isDarkMode,
                              onToggleChanged: (value) {
                                themeProvider.toggleTheme(value);
                              },
                            );
                          }
                      ),
                      buildSettingItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notification',
                        hasToggle: false,
                        toggleValue: notificationAlertsEnabled,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationSettingsScreen(
                                initialValue: notificationAlertsEnabled,
                                onSettingsChanged: (value) {
                                  setState(() {
                                    notificationAlertsEnabled = value;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      buildSettingItem(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        title: tr('How to screenshot'),
                        hasToggle: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlantPhotographyGuideScreen(), // إضافة const
                            ),
                          );
                        },
                      ),
                      buildSettingItem(
                        context: context,
                        icon: Icons.sentiment_satisfied_outlined,
                        title: tr('Support Us'),
                        hasToggle: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteHelper.navigateTo(const ContactSupportScreen()),
                          );
                        },
                      ),
                      buildSettingItem(
                        context: context,
                        icon: Icons.sentiment_satisfied_outlined,
                        title: 'Privacy Policy',
                        hasToggle: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteHelper.navigateTo(const PrivacyPolicyScreen()),
                          );
                        },
                      ),
                      buildSettingItem(
                        context: context,
                        icon: Icons.logout,
                        title: 'log out',
                        hasToggle: false,
                        isLogout: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('log out'),
                                content: Text(
                                  tr('Are you sure logout'),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(tr('cancel')),
                                  ),
                                  SizedBox(height: 15,),
                                  TextButton(
                                    onPressed: () async{
                                      await authViewModel.signOut(context);
                                      Restart.restartApp();

                                    },
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: Text(tr('log out')),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

}