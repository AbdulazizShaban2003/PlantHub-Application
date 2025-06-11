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

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Test notification to verify setup
    await _testNotification();
  }

  Future<void> _testNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'MyPlant Setup Complete',
        'Notifications are working correctly!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Test notification channel',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('Test notification sent successfully');
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      print('Android notification permission granted: $granted');

      final bool? exactAlarmGranted = await androidImplementation?.requestExactAlarmsPermission();
      print('Android exact alarm permission granted: $exactAlarmGranted');
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
      _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final bool? granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      print('iOS notification permission granted: $granted');
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final String? payload = response.payload;
    print('Notification tapped with payload: $payload');

    if (payload != null && payload != 'test') {
      // Mark notification as read
      await _databaseHelper.markNotificationAsRead(payload);

      // Update in Firebase
      try {
        await _firebaseService.markNotificationAsRead(payload);
      } catch (e) {
        print('Error updating notification in Firebase: $e');
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

      print('Scheduling reminder for ${plant.name} - ${action.type.displayName}');

      // Get plant thumbnail
      final String? thumbnailPath = await _databaseHelper.getMainPlantImage(plant.id);

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

      // Save to local database
      await _databaseHelper.insertNotification(notification);

      // Save to Firebase
      await _firebaseService.saveNotification(notification);

      // Schedule local notification
      await _scheduleLocalNotification(notification, reminder);

      print('Reminder scheduled successfully: ${notification.title}');

    } catch (e) {
      print('Error scheduling reminder: $e');
      rethrow;
    }
  }

  Future<void> _scheduleLocalNotification(
      NotificationModel notification,
      Reminder reminder,
      ) async {
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
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
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

    print('Current time: $now');
    print('Scheduled time: $scheduledDate');

    // If scheduled time is in the past, schedule for next occurrence
    tz.TZDateTime finalScheduledDate = scheduledDate;
    if (scheduledDate.isBefore(now)) {
      switch (reminder.repeat) {
        case RepeatType.daily:
          finalScheduledDate = scheduledDate.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          finalScheduledDate = scheduledDate.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          finalScheduledDate = tz.TZDateTime(
            tz.local,
            scheduledDate.year,
            scheduledDate.month + 1,
            scheduledDate.day,
            scheduledDate.hour,
            scheduledDate.minute,
          );
          break;
        case RepeatType.once:
        // For one-time reminders in the past, schedule for 1 minute from now for testing
          finalScheduledDate = now.add(const Duration(minutes: 1));
          break;
      }
      print('Adjusted scheduled time: $finalScheduledDate');
    }

    try {
      final int notificationId = notification.id.hashCode.abs();

      if (reminder.repeat == RepeatType.once) {
        // For one-time notifications
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,
          matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.alarmClock,

        );
      } else {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,
          androidScheduleMode: AndroidScheduleMode.alarmClock,

          matchDateTimeComponents: _getDateTimeComponents(reminder.repeat),
        );
      }

      print('Notification scheduled with ID: $notificationId at $finalScheduledDate');

      await scheduleTestNotification(notification);

    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleTestNotification(NotificationModel notification) async {
    try {
      final tz.TZDateTime testTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // Test notification ID
        '🧪 Test: ${notification.title}',
        'This is a test notification for ${notification.body}',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_reminders',
            'Test Plant Reminders',
            channelDescription: 'Test notifications for plant reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test',
        matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: AndroidScheduleMode.alarmClock,

      );

      print('Test notification scheduled for $testTime');
    } catch (e) {
      print('Error scheduling test notification: $e');
    }
  }

  DateTimeComponents? _getDateTimeComponents(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatType.once:
        return null;
    }
  }

  Future<void> cancelReminder(String notificationId) async {
    try {
      final int id = notificationId.hashCode.abs();
      await _flutterLocalNotificationsPlugin.cancel(id);
      await _databaseHelper.deleteNotification(notificationId);
      await _firebaseService.deleteNotification(notificationId);
      print('Reminder cancelled: $notificationId');
    } catch (e) {
      print('Error canceling reminder: $e');
    }
  }

  Future<void> cancelAllPlantReminders(String plantId) async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      final List<NotificationModel> notifications =
      await _databaseHelper.getUserNotifications(userId);

      for (final notification in notifications) {
        if (notification.plantId == plantId) {
          await cancelReminder(notification.id);
        }
      }
    } catch (e) {
      print('Error canceling plant reminders: $e');
    }
  }

  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      return await _databaseHelper.getUserNotifications(userId);
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _databaseHelper.markNotificationAsRead(notificationId);
      await _firebaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markNotificationAsDelivered(String notificationId) async {
    try {
      await _databaseHelper.markNotificationAsDelivered(notificationId);
      await _firebaseService.markNotificationAsDelivered(notificationId);
    } catch (e) {
      print('Error marking notification as delivered: $e');
    }
  }
}
