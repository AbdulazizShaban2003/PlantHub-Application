import 'package:flutter/material.dart';
import 'package:plant_hub_app/config/routes/route_helper.dart';
import 'package:plant_hub_app/config/theme/app_colors.dart';
import 'package:plant_hub_app/core/provider/language_provider.dart';
import 'package:plant_hub_app/core/utils/size_config.dart';
import 'package:plant_hub_app/core/widgets/outlined_button_widget.dart';
import 'package:plant_hub_app/features/account/presentation/views/privacy_policy_screen.dart';
import 'package:plant_hub_app/features/account/presentation/views/support_us_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/provider/theme_provider.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../auth/presentation/manager/auth_provider.dart';
import '../../../notification/notification_settings_screen.dart';
import '../components/build_language_setting_item.dart';
import '../components/build_setting_item_component.dart';
import '../widgets/custom_profile_widget.dart';
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
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final authViewModel = Provider.of<AuthProviderManager>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240.0,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
        
                  return FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                        child: CustomHeaderProfileWidget(),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig().width(0.03)),
                child: Column(
                  children: [
                    _buildLanguageSetting(),
                    _buildThemeSetting(),
                    _buildNotificationSetting(),
                    SizedBox(height: SizeConfig().height(0.02)),
                    _buildPhotographyGuide(),
                    _buildSupportUs(),
                    _buildPrivacyPolicy(),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildLanguageSetting() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return buildLanguageSettingItem(context, languageProvider);
      },
    );
  }

  Widget _buildThemeSetting() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return buildSettingItem(
          context: context,
          icon: Icons.dark_mode_outlined,
          title: AppStrings.darkMode,
          hasToggle: true,
          toggleValue: themeProvider.isDarkMode,
          onToggleChanged: (value) {
            themeProvider.toggleTheme(value);
          },
        );
      },
    );
  }

  Widget _buildNotificationSetting() {
    return buildSettingItem(
      context: context,
      icon: Icons.notifications_outlined,
      title: AppStrings.notifications,
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
    );
  }

  Widget _buildPhotographyGuide() {
    return buildSettingItem(
      context: context,
      icon: Icons.camera_alt_outlined,
      title: AppStrings.photographyGuide,
      hasToggle: false,
      onTap: () {
        Navigator.push(
          context,
          RouteHelper.navigateTo(const PlantPhotographyGuideScreen()),
        );
      },
    );
  }

  Widget _buildSupportUs() {
    return buildSettingItem(
      context: context,
      icon: Icons.sentiment_satisfied_outlined,
      title: AppStrings.supportUs,
      hasToggle: false,
      onTap: () {
        Navigator.push(
          context,
          RouteHelper.navigateTo(const ContactSupportScreen()),
        );
      },
    );
  }

  Widget _buildPrivacyPolicy() {
    return buildSettingItem(
      context: context,
      icon: Icons.privacy_tip_outlined,
      title: AppStrings.privacyPolicy,
      hasToggle: false,
      onTap: () {
        Navigator.push(
          context,
          RouteHelper.navigateTo(const PrivacyPolicyScreen()),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return buildSettingItem(
      context: context,
      icon: Icons.logout,
      title: AppStrings.logout,
      hasToggle: false,
      isLogout: true,
      onTap: _showLogoutConfirmationDialog,
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              AppStrings.logoutConfirmation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          contentPadding: EdgeInsets.all(SizeConfig().width(0.04)),
          actions: [
            Column(
              children: [
                OutlinedButtonWidget(
                  nameButton: AppStrings.logout,
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Add your logout logic here
                  },
                  foregroundColor: ColorsManager.redColor,
                  backgroundColor: ColorsManager.whiteColor,
                ),
                SizedBox(height: SizeConfig().height(0.015)),
                OutlinedButtonWidget(
                  nameButton: AppStrings.cancel,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: SizeConfig().responsiveFont(14)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}