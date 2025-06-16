import 'package:flutter/material.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../my_plant/services/notification_service.dart'; //

class NotificationSettingsScreen extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onSettingsChanged;

  const NotificationSettingsScreen({
    super.key,
    required this.initialValue,
    required this.onSettingsChanged,
  });

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late bool _notificationsEnabled;
  bool _newMessageNotifications = true;
  bool _activityNotifications = true;
  bool _promotionalNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { //
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    }); //
  } //

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              AppStrings.notificationSettingsTitle,
              style: TextStyle(
                fontSize: SizeConfig().responsiveFont(18),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: SizeConfig().responsiveFont(24),
              ),
              onPressed: () {
                widget.onSettingsChanged(_notificationsEnabled);
                Navigator.pop(context);
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(SizeConfig().width(0.04)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMasterSwitch(),
                Divider(height: SizeConfig().height(0.03)),
                if (_notificationsEnabled) ...[
                  _buildSectionTitle(AppStrings.notificationTypes),
                  _buildNotificationTypeSwitch(
                    AppStrings.newMessages,
                    AppStrings.newMessagesDesc,
                    _newMessageNotifications,
                        (value) {
                      setState(() {
                        _newMessageNotifications = value;
                      });
                    },
                  ),
                  _buildNotificationTypeSwitch(
                    AppStrings.activityUpdates,
                    AppStrings.activityUpdatesDesc,
                    _activityNotifications,
                        (value) {
                      setState(() {
                        _activityNotifications = value;
                      });
                    },
                  ),
                  _buildNotificationTypeSwitch(
                    AppStrings.promotional,
                    AppStrings.promotionalDesc,
                    _promotionalNotifications,
                        (value) {
                      setState(() {
                        _promotionalNotifications = value;
                      });
                    },
                  ),
                  SizedBox(height: SizeConfig().height(0.025)),
                  _buildSectionTitle(AppStrings.notificationSettings),
                  _buildNotificationTypeSwitch(
                    AppStrings.sound,
                    AppStrings.soundDesc,
                    _soundEnabled,
                        (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    },
                  ),
                  _buildNotificationTypeSwitch(
                    AppStrings.vibration,
                    AppStrings.vibrationDesc,
                    _vibrationEnabled,
                        (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig().width(0.04)),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              size: SizeConfig().responsiveFont(28),
              color: _notificationsEnabled ? Colors.green : Colors.grey,
            ),
            SizedBox(width: SizeConfig().width(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.enableNotifications,
                    style: TextStyle(
                      fontSize: SizeConfig().responsiveFont(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.turnOnOffAll,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: SizeConfig().responsiveFont(14),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) async { //
                setState(() { //
                  _notificationsEnabled = value; //
                }); //
                final prefs = await SharedPreferences.getInstance(); //
                await prefs.setBool('notificationsEnabled', value); //

                if (!value) { //
                  await NotificationService().cancelAllNotifications(); //
                  print('All notifications cancelled due to global setting.'); //
                } //
                widget.onSettingsChanged(value); //
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig().height(0.01)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: SizeConfig().responsiveFont(16),
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeSwitch(
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig().height(0.01)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeConfig().responsiveFont(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: SizeConfig().responsiveFont(14),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}