import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app/my_app.dart';
import 'core/cache/cache_helper.dart';
import 'core/service/service_locator.dart';
import 'features/my_plant/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await setup();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await sl<CacheHelper>().init();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'An error occurred, please try again later.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  tz.initializeTimeZones();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
  await notificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String? initialRoute;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final String? payload = notificationAppLaunchDetails!.notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      print('App launched by notification with payload: $payload');
    }
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      saveLocale: true,
      child: PlantHub(cameras: cameras),
    ),
  );
}
