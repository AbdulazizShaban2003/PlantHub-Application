import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/database_helper.dart';
import 'firebase_service_notification.dart' show FirebaseService;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  Future<void> initialize() async {
    try {
      print('🔧 Initializing notification service...');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );

      print('📱 Notification plugin initialized: $initialized');

      // Request permissions with better error handling
      await _requestPermissions();

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          // Request notification permission
          final bool? granted =
              await androidImplementation.requestNotificationsPermission();
          print('🔔 Android notification permission granted: $granted');

          if (granted != true) {
            print(
              '⚠️ Notification permission denied - notifications may not work',
            );
          }

          // Request exact alarm permission for Android 12+
          final bool? exactAlarmGranted =
              await androidImplementation.requestExactAlarmsPermission();
          print('⏰ Android exact alarm permission granted: $exactAlarmGranted');

          if (exactAlarmGranted != true) {
            print(
              '⚠️ Exact alarm permission denied - scheduled notifications may not work when app is closed',
            );
          }
        }
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        if (iosImplementation != null) {
          final bool? granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print('🍎 iOS notification permission granted: $granted');

          if (granted != true) {
            print('⚠️ iOS notification permission denied');
          }
        }
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      // Continue with initialization even if permissions fail
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final String? payload = response.payload;
    print('👆 Notification tapped with payload: $payload');

    if (payload != null && payload != 'test_notification') {
      try {
        // Mark notification as read in both local and Firebase
        await _databaseHelper.markNotificationAsRead(payload);
        await _firebaseService.markNotificationAsRead(payload);

        print('✅ Notification marked as read: $payload');
      } catch (e) {
        print('❌ Error marking notification as read: $e');
      }
    }
  }

  Future<void> scheduleReminder({
    required Plant plant,
    required PlantAction action,
    required Reminder reminder,
  }) async {
    try {
      final String notificationId = _uuid.v4();
      final String userId = _firebaseService.currentUserId ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      print(
        '📅 Scheduling reminder for ${plant.name} - ${action.type.displayName}',
      );

      // Get plant thumbnail from local database
      final String? thumbnailPath = await _databaseHelper.getMainPlantImage(
        plant.id,
      );

      // Create notification model
      final NotificationModel notification = NotificationModel(
        id: notificationId,
        userId: userId,
        plantId: plant.id,
        plantName: plant.name,
        actionType: action.type.name,
        title: '🌱 ${action.type.displayName} Time!',
        body: 'Time to ${reminder.remindMeTo.toLowerCase()} for ${plant.name}',
        thumbnailPath: thumbnailPath ?? '',
        taskNames: reminder.tasks,
        scheduledTime: reminder.time,
        isDelivered: false,
        isRead: false,
      );

      // Save to local database first
      await _databaseHelper.insertNotification(notification);
      print('💾 Notification saved to local database');

      // Save to Firebase
      await _firebaseService.saveNotification(notification);
      print('☁️ Notification saved to Firebase');

      // Schedule local notification for background delivery
      await _scheduleLocalNotification(notification, reminder);

      print('✅ Reminder scheduled successfully: ${notification.title}');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
      rethrow;
    }
  }

  Future<void> _scheduleLocalNotification(
    NotificationModel notification,
    Reminder reminder,
  ) async {
    try {
      // Enhanced Android notification details for background delivery
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'plant_reminders',
            'Plant Care Reminders',
            channelDescription: 'Notifications for plant care reminders',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            autoCancel: false,
            ongoing: false,
            enableLights: true,
            ledOnMs: 1000,
            ledOffMs: 500,
            // Ensure notification works when app is closed
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
            // Ensure notification works when app is closed
            interruptionLevel: InterruptionLevel.active,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminder.time,
        tz.local,
      );

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      print('⏰ Current time: $now');
      print('📅 Scheduled time: $scheduledDate');

      // Calculate final scheduled date
      tz.TZDateTime finalScheduledDate = scheduledDate;

      // If scheduled time is in the past, calculate next occurrence based on repeat type
      if (scheduledDate.isBefore(now)) {
        switch (reminder.repeat) {
          case RepeatType.daily:
            // Schedule for next day at same time
            finalScheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day + 1,
              scheduledDate.hour,
              scheduledDate.minute,
            );
            break;
          case RepeatType.weekly:
            // Schedule for next week at same time
            finalScheduledDate = scheduledDate.add(const Duration(days: 7));
            while (finalScheduledDate.isBefore(now)) {
              finalScheduledDate = finalScheduledDate.add(
                const Duration(days: 7),
              );
            }
            break;
          case RepeatType.monthly:
            // Schedule for next month at same time
            finalScheduledDate = tz.TZDateTime(
              tz.local,
              scheduledDate.month == 12
                  ? scheduledDate.year + 1
                  : scheduledDate.year,
              scheduledDate.month == 12 ? 1 : scheduledDate.month + 1,
              scheduledDate.day,
              scheduledDate.hour,
              scheduledDate.minute,
            );
            break;
          case RepeatType.once:
            // For testing, schedule 30 seconds from now
            finalScheduledDate = now.add(const Duration(seconds: 30));
            break;
        }
        print('🔄 Adjusted scheduled time: $finalScheduledDate');
      }

      final int notificationId = notification.id.hashCode.abs();

      // Schedule the notification with proper repeat settings
      if (reminder.repeat == RepeatType.once) {
        // One-time notification
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        // Repeating notification
        DateTimeComponents? matchDateTimeComponents;
        switch (reminder.repeat) {
          case RepeatType.daily:
            matchDateTimeComponents = DateTimeComponents.time;
            break;
          case RepeatType.weekly:
            matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
            break;
          case RepeatType.monthly:
            matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
            break;
          case RepeatType.once:
            matchDateTimeComponents = null;
            break;
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,

          matchDateTimeComponents: matchDateTimeComponents,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }

      print(
        '✅ Local notification scheduled with ID: $notificationId at $finalScheduledDate',
      );

      // Schedule automatic delivery marking
      _scheduleDeliveryMarking(notification.id, finalScheduledDate, now);
    } catch (e) {
      print('❌ Error scheduling local notification: $e');
      rethrow;
    }
  }

  void _scheduleDeliveryMarking(
    String notificationId,
    tz.TZDateTime scheduledTime,
    tz.TZDateTime now,
  ) {
    final Duration delay = scheduledTime.difference(now);
    if (delay.isNegative) return;

    Future.delayed(delay, () async {
      try {
        await markNotificationAsDelivered(notificationId);
        print('✅ Notification marked as delivered: $notificationId');
      } catch (e) {
        print('❌ Error marking notification as delivered: $e');
      }
    });
  }

  Future<void> scheduleTestNotification() async {
    try {
      print('🧪 Starting test notification...');

      // Check notification permissions
      if (Platform.isAndroid) {
        final bool? areNotificationsEnabled =
            await _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.areNotificationsEnabled();

        if (areNotificationsEnabled == false) {
          throw Exception(
            'Notifications are disabled. Please enable them in device settings.',
          );
        }
      }

      final tz.TZDateTime testTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 5));
      print('⏰ Test notification scheduled for: $testTime');

      // Create test notification with enhanced settings
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // Fixed test ID
        '🧪 Test Notification',
        'MyPlant notification system is working correctly!',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notification channel for MyPlant',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            showWhen: true,
            autoCancel: true,
            enableLights: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'test_notification',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print('✅ Test notification scheduled successfully');

      // Optionally save test notification to database
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isNotEmpty) {
        try {
          final String notificationId =
              'test_${DateTime.now().millisecondsSinceEpoch}';
          final NotificationModel testNotification = NotificationModel(
            id: notificationId,
            userId: userId,
            plantId: 'test_plant',
            plantName: 'Test Plant',
            actionType: ActionType.watering.name,
            title: '🧪 Test Notification',
            body: 'MyPlant notification system is working correctly!',
            thumbnailPath: '',
            taskNames: ['Test notification'],
            scheduledTime: testTime.toLocal(),
            isDelivered: false,
            isRead: false,
          );

          await _databaseHelper.insertNotification(testNotification);
          await _firebaseService.saveNotification(testNotification);
          print('💾 Test notification saved to databases');
        } catch (e) {
          print('⚠️ Could not save test notification to database: $e');
        }
      }
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
      rethrow;
    }
  }

  Future<void> cancelReminder(String notificationId) async {
    try {
      final int id = notificationId.hashCode.abs();
      await _flutterLocalNotificationsPlugin.cancel(id);
      await _databaseHelper.deleteNotification(notificationId);
      await _firebaseService.deleteNotification(notificationId);
      print('🗑️ Reminder cancelled: $notificationId');
    } catch (e) {
      print('❌ Error canceling reminder: $e');
    }
  }

  Future<void> cancelAllPlantReminders(String plantId) async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      final List<NotificationModel> notifications = await _databaseHelper
          .getUserNotifications(userId);

      for (final notification in notifications) {
        if (notification.plantId == plantId) {
          await cancelReminder(notification.id);
        }
      }
      print('🗑️ All reminders cancelled for plant: $plantId');
    } catch (e) {
      print('❌ Error canceling plant reminders: $e');
    }
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isEmpty) return [];

      // Get notifications from Firebase first
      final List<NotificationModel> firebaseNotifications =
          await _firebaseService.getUserNotifications();

      // Get notifications from local database
      final List<NotificationModel> localNotifications = await _databaseHelper
          .getUserNotifications(userId);

      // Merge notifications, prioritizing Firebase data but keeping local image paths
      final Map<String, NotificationModel> mergedNotifications = {};

      // Add local notifications first
      for (final notification in localNotifications) {
        mergedNotifications[notification.id] = notification;
      }

      // Override with Firebase notifications, but keep local image paths
      for (final notification in firebaseNotifications) {
        final localNotification = mergedNotifications[notification.id];
        if (localNotification != null) {
          // Keep local image path
          mergedNotifications[notification.id] = notification.copyWith(
            thumbnailPath: localNotification.thumbnailPath,
          );
        } else {
          mergedNotifications[notification.id] = notification;
        }

        // Update local database with Firebase data
        await _databaseHelper.insertNotification(
          mergedNotifications[notification.id]!,
        );
      }

      final List<NotificationModel> result =
          mergedNotifications.values.toList()
            ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      print('📦 Merged ${result.length} notifications');
      return result;
    } catch (e) {
      print('❌ Error getting user notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _databaseHelper.markNotificationAsRead(notificationId);
      await _firebaseService.markNotificationAsRead(notificationId);
      print('📖 Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markNotificationAsDelivered(String notificationId) async {
    try {
      await _databaseHelper.markNotificationAsDelivered(notificationId);
      await _firebaseService.markNotificationAsDelivered(notificationId);
      print('📬 Notification marked as delivered: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as delivered: $e');
    }
  }
}
