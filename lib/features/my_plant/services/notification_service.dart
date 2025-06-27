import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// تأكد من أن هذه المسارات صحيحة لمشروعك
import '../data/models/notification_model.dart';

import '../services/database_helper.dart';
import 'firebase_service_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirebaseServiceNotify _firebaseService = FirebaseServiceNotify();
  final Uuid _uuid = const Uuid();

   Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'instant_channel_id',
      'Instant Notifications',
      channelDescription: 'Notifications shown immediately upon app launch',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  Future<void> initialize() async {
    try {
      print('🔧 Initializing notification service...');

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTappedBackground, // Add this for background handling
      );

      print('📱 Notification plugin initialized: $initialized');

      // طلب الأذونات الخاصة بالمنصة.
      await _requestPermissions();

      // التحقق مما إذا كانت الإشعارات ممكّنة عالميًا بواسطة المستخدم في إعدادات التطبيق.
      final bool globallyEnabled = await _areNotificationsGloballyEnabled();
      if (!globallyEnabled) {
        print(
          '⚠️ Notifications globally disabled. Cancelling any pending notifications.',
        );
        await cancelAllNotifications(); // إلغاء الإشعارات المعلقة إذا كانت معطلة عالميًا.
      }

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow; // إعادة رمي الخطأ للمعالجة الخارجية.
    }
  }

  static void _onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload,
      ) async {
    // هذا الـ callback مخصص لـ iOS < 10.0 عندما يكون التطبيق في المقدمة.
    // قد ترغب في عرض مربع حوار تنبيه هنا أو التعامل معه بشكل مختلف.
    print('🍎 iOS received notification (legacy): $id, $title, $body, $payload');
    // على سبيل المثال، يمكنك عرض إشعار مخصص داخل التطبيق هنا.
  }

  /// يطلب الأذونات الضرورية للإشعارات بناءً على المنصة.
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // طلب إذن الإشعارات العام لأندرويد.
          // هذا ضروري لأندرويد 13 (API 33) وما فوق.
          final bool? granted =
          await androidImplementation.requestNotificationsPermission();
          print('🔔 Android notification permission granted: $granted');

          if (granted != true) {
            print(
              '⚠️ Notification permission denied - notifications may not work. You might need to prompt the user to enable them in settings.',
            );
            // يمكنك هنا عرض حوار يطلب من المستخدم الانتقال إلى الإعدادات لتمكين الإشعارات
            // openAppSettings(); // تتطلب حزمة permission_handler
          }

          // طلب إذن التنبيهات الدقيقة لأندرويد (API 31+ للتوقيت الدقيق).
          // هذا مهم لكي يتم تشغيل الإشعارات المجدولة في الأوقات الدقيقة،
          // خاصة عندما يكون الجهاز خاملاً أو في وضع doze.
          final bool? exactAlarmGranted =
          await androidImplementation.requestExactAlarmsPermission();
          print('⏰ Android exact alarm permission granted: $exactAlarmGranted');

          if (exactAlarmGranted != true) {
            print(
              '⚠️ Exact alarm permission denied - scheduled notifications may not work when app is closed. Consider showing a dialog.',
            );
          }
        }
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          // طلب الأذونات لـ iOS.
          final bool? granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print('🍎 iOS notification permission granted: $granted');

          if (granted != true) {
            print('⚠️ iOS notification permission denied. Notifications might not appear.');
            // يمكنك توجيه المستخدم إلى إعدادات التطبيق لتمكين الأذونات
            // openAppSettings(); // تتطلب حزمة permission_handler
          }
        }
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Callback عند النقر على إشعار.
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final String? payload = response.payload;
    print('👆 Notification tapped with payload: $payload');

    // المعالجة فقط إذا كان هناك payload صالح (وليس إشعار اختباري).
    if (payload != null && payload != 'test_notification') {
      try {
        // وضع علامة "مقروء" على الإشعار في قواعد البيانات المحلية و Firebase.
        await _databaseHelper.markNotificationAsRead(payload);
        await _firebaseService.markNotificationAsRead(payload);

        print('✅ Notification marked as read: $payload');

        // قد ترغب في الانتقال إلى شاشة معينة بناءً على الـ payload.
        // على سبيل المثال:
        // Navigator.of(GlobalKey<NavigatorState>().currentContext!).pushNamed('/notification_details', arguments: payload);
      } catch (e) {
        print('❌ Error marking notification as read: $e');
      }
    }
  }

  // Callback for notifications received when the app is in the background or terminated
  @pragma('vm:entry-point') // Required for functions executed in isolation (background)
  static void _onNotificationTappedBackground(NotificationResponse response) {
    final String? payload = response.payload;
    print('👆 Background notification tapped with payload: $payload');
    // Handle background notification tap here. This typically involves navigating
    // to a specific screen when the app is opened from the notification.
    // Note: You cannot directly update UI or access Flutter context here.
    // You might want to save the payload to SharedPreferences and then
    // process it when the app starts.
  }

  /// يتحقق مما إذا كانت الإشعارات ممكّنة عالميًا في تفضيلات المستخدم.
  Future<bool> _areNotificationsGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // الافتراضي هو true إذا لم يتم تعيين التفضيل.
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  /// يلغي جميع الإشعارات المعلقة والمعروضة.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('🗑️ All notifications cancelled.');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// يجدول إشعار تذكير لإجراء معين على نبات.
  Future<void> scheduleReminder({
    required Plant plant,
    required PlantAction action,
    required Reminder reminder,
  }) async {
    try {
      final bool globallyEnabled = await _areNotificationsGloballyEnabled();
      if (!globallyEnabled) {
        print('🚫 Global notifications are disabled. Not scheduling reminder.');
        return;
      }

      final String notificationId = _uuid.v4(); // إنشاء معرف فريد.
      final String userId = _firebaseService.currentUserId ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated. Cannot schedule reminder.');
      }

      print(
        '📅 Scheduling reminder for ${plant.name} - ${action.type.displayName}',
      );

      // الحصول على مسار الصورة المصغرة للإشعار.
      final String? thumbnailPath = await _databaseHelper.getMainPlantImage(
        plant.id,
      );

      // إنشاء instance من NotificationModel.
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

      await _databaseHelper.insertNotification(notification);
      print('💾 Notification saved to local database');

      await _firebaseService.saveNotification(notification);
      print('☁️ Notification saved to Firebase');

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
      // تفاصيل الإشعار الخاصة بأندرويد.
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'plant_reminders', // معرف القناة
        'Plant Care Reminders', // اسم القناة
        channelDescription: 'Notifications for plant care reminders',
        importance: Importance.max, // أهمية عالية لإشعارات Heads-up (تظهر في الجزء العلوي من الشاشة)
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        autoCancel: false, // الإشعار يبقى حتى يتم رفضه من قبل المستخدم
        ongoing: false, // ليس إشعارًا مستمرًا
        enableLights: true,
        ledColor: Colors.green, // مثال على لون LED
        ledOnMs: 1000,
        ledOffMs: 500,
        // fullScreenIntent: true, // استخدم بحذر، يمكن أن يكون مزعجًا
        category: AndroidNotificationCategory.reminder, // تصنيف كـ "تذكير"
      );

      // تفاصيل الإشعار الخاصة بـ iOS.
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default', // استخدام الصوت الافتراضي
        badgeNumber: 1, // زيادة عدد الشارة
        interruptionLevel: InterruptionLevel.active, // يضمن التسليم الفوري
      );

      // تفاصيل المنصة المجمعة.
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Convert DateTime to TZDateTime for timezone handling.
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminder.time,
        tz.local,
      );
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      print('⏰ Current time: $now');
      print('📅 Scheduled time (raw): $scheduledDate');

      tz.TZDateTime finalScheduledDate = scheduledDate;

      // Adjust scheduled date if it's in the past for recurring reminders.
      if (scheduledDate.isBefore(now)) {
        switch (reminder.repeat) {
          case RepeatType.daily:
          // جدولة لغدًا في نفس الوقت.
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
          // جدولة للحدوث التالي لنفس اليوم من الأسبوع.
            finalScheduledDate = scheduledDate.add(const Duration(days: 7));
            while (finalScheduledDate.isBefore(now)) {
              finalScheduledDate = finalScheduledDate.add(
                const Duration(days: 7),
              );
            }
            break;
          case RepeatType.monthly:
          // جدولة لنفس اليوم من الشهر التالي.
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
            // معالجة حالة نهاية الشهر (على سبيل المثال، 30 فبراير -> 2 مارس)
            if (finalScheduledDate.day != scheduledDate.day) {
              finalScheduledDate = tz.TZDateTime(
                  tz.local,
                  finalScheduledDate.year,
                  finalScheduledDate.month,
                  1 // اليوم الأول من الشهر التالي
              )
                  .add(const Duration(days: -1)); // اليوم الأخير من الشهر السابق
              finalScheduledDate = tz.TZDateTime(
                  tz.local,
                  finalScheduledDate.year,
                  finalScheduledDate.month,
                  finalScheduledDate.day,
                  scheduledDate.hour,
                  scheduledDate.minute);
            }
            break;
          case RepeatType.once:
          // للتذكيرات التي تحدث "مرة واحدة"، إذا كانت في الماضي، جدولة لتأخير قصير.
          // هذا هو حل بديل لضمان تشغيلها، ولكن التذكيرات المثالية "مرة واحدة"
          // لا يجب أن يتم جدولتها للماضي.
            finalScheduledDate = now.add(const Duration(seconds: 30));
            print('⚠️ "Once" reminder was in the past, scheduling for 30s from now.');
            break;
        }
        print('🔄 Adjusted scheduled time: $finalScheduledDate');
      }

      // إنشاء معرف رقمي فريد للإشعار المحلي.
      final int notificationId = notification.id.hashCode.abs();

      // جدولة الإشعار بناءً على نوع التكرار.
      if (reminder.repeat == RepeatType.once) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,
          // Use inexactAllowWhileIdle for one-time events,
          // unless strict exactness is critical and permissions are guaranteed.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // uiLocalNotificationDateInterpretation and UILocalNotificationDateInterpretation.absoluteTime are removed
          // as they are no longer valid parameters in newer flutter_local_notifications versions.
        );
      } else {
        DateTimeComponents? matchDateTimeComponents;
        switch (reminder.repeat) {
          case RepeatType.daily:
            matchDateTimeComponents =
                DateTimeComponents.time; // تكرار يومي في هذا الوقت.
            break;
          case RepeatType.weekly:
            matchDateTimeComponents = DateTimeComponents
                .dayOfWeekAndTime; // تكرار أسبوعي في هذا اليوم والوقت.
            break;
          case RepeatType.monthly:
            matchDateTimeComponents = DateTimeComponents
                .dayOfMonthAndTime; // تكرار شهري في هذا اليوم والوقت.
            break;
          case RepeatType.once:
            matchDateTimeComponents =
            null; // تم التعامل معها بواسطة الـ 'if' أعلاه.
            break;
        }

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          notification.title,
          notification.body,
          finalScheduledDate,
          platformChannelSpecifics,
          payload: notification.id,
          matchDateTimeComponents:
          matchDateTimeComponents, // للإشعارات المتكررة.
          // Use inexactAllowWhileIdle for recurring, as exact is not typically needed
          // and consumes more battery. If precise repeats are crucial, ensure
          // exact alarms permission is handled.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          // uiLocalNotificationDateInterpretation and UILocalNotificationDateInterpretation.absoluteTime are removed
          // as they are no longer valid parameters in newer flutter_local_notifications versions.
        );
      }

      print(
        '✅ Local notification scheduled with ID: $notificationId at $finalScheduledDate',
      );

      // جدولة وضع علامة "تم التسليم" تلقائيًا بعد الوقت المتوقع لتشغيل الإشعار.
      _scheduleDeliveryMarking(notification.id, finalScheduledDate, now);
    } catch (e) {
      print('❌ Error scheduling local notification: $e');
      rethrow;
    }
  }

  /// يجدول مهمة مؤجلة لوضع علامة "تم التسليم" على الإشعار في قاعدة البيانات.
  void _scheduleDeliveryMarking(
      String notificationId,
      tz.TZDateTime scheduledTime,
      tz.TZDateTime now,
      ) {
    // حساب التأخير حتى الوقت المتوقع لتشغيل الإشعار.
    Duration delay = scheduledTime.difference(now);
    // إذا كان الوقت المجدول في الماضي (على سبيل المثال، تم تعديله إلى 'الآن + 30 ثانية')،
    // تأكد من أن التأخير ليس سالبًا.
    if (delay.isNegative) {
      delay =
      const Duration(seconds: 5); // ضع علامة "تم التسليم" بعد فترة وجيزة إذا كان مستحقًا بالفعل.
    }

    Future.delayed(delay, () async {
      try {
        await markNotificationAsDelivered(notificationId);
        print('✅ Notification marked as delivered: $notificationId');
      } catch (e) {
        print('❌ Error marking notification as delivered: $e');
      }
    });
  }

  /// يجدول إشعارًا اختباريًا للتحقق من وظائف النظام.
  Future<void> scheduleTestNotification() async {
    try {
      final bool globallyEnabled = await _areNotificationsGloballyEnabled();
      if (!globallyEnabled) {
        print(
          '🚫 Global notifications are disabled. Not scheduling test notification.',
        );
        return;
      }

      print('🧪 Starting test notification...');

      if (Platform.isAndroid) {
        // تحقق مزدوج مما إذا كانت الإشعارات ممكّنة للتطبيق على أندرويد.
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool? areNotificationsEnabled =
          await androidImplementation.areNotificationsEnabled();

          if (areNotificationsEnabled == false) {
            print(
              '⚠️ Notifications are disabled for the app. Please enable them in device settings to receive test notifications.',
            );
            // يمكنك هنا أن تطلب من المستخدم فتح إعدادات التطبيق
            // await openAppSettings(); // تتطلب حزمة permission_handler
            return; // لا تكمل جدولة الإشعار إذا كانت معطلة على مستوى التطبيق
          }
        }
      }

      // جدولة إشعار اختباري لمدة 5 ثوانٍ من الآن.
      final tz.TZDateTime testTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 5));
      print('⏰ Test notification scheduled for: $testTime');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // معرف فريد للإشعار الاختباري.
        '🧪 Test Notification',
        'MyPlant notification system is working correctly!',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel', // قناة منفصلة لإشعارات الاختبار.
            'Test Notifications',
            channelDescription: 'Test notification channel for MyPlant',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            showWhen: true,
            autoCancel: true, // إشعارات الاختبار يمكن أن تلغي نفسها تلقائيًا.
            enableLights: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        payload: 'test_notification', // payload محدد للاختبار.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation and UILocalNotificationDateInterpretation.absoluteTime are removed
        // as they are no longer valid parameters in newer flutter_local_notifications versions.
      );

      print('✅ Test notification scheduled successfully');

      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isNotEmpty) {
        try {
          // حفظ سجل الإشعار الاختباري في قاعدة البيانات.
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

  /// يلغي تذكيرًا محددًا بواسطة معرّفه.
  Future<void> cancelReminder(String notificationId) async {
    try {
      final int id =
      notificationId.hashCode.abs(); // الحصول على المعرف الرقمي المستخدم للإشعارات المحلية.
      await _flutterLocalNotificationsPlugin.cancel(id); // إلغاء الإشعار المحلي.
      await _databaseHelper.deleteNotification(notificationId); // الحذف من قاعدة البيانات المحلية.
      await _firebaseService.deleteNotification(notificationId); // الحذف من Firebase.
      print('🗑️ Reminder cancelled: $notificationId');
    } catch (e) {
      print('❌ Error canceling reminder: $e');
    }
  }

  /// يلغي جميع التذكيرات المرتبطة بنبات معين.
  Future<void> cancelAllPlantReminders(String plantId) async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isEmpty) return; // لا يوجد مستخدم، لا توجد تذكيرات للإلغاء.

      // الحصول على جميع الإشعارات للمستخدم.
      final List<NotificationModel> notifications =
      await _databaseHelper.getUserNotifications(userId);

      // التكرار وإلغاء الإشعارات المتعلقة بالنبات المحدد.
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

  /// يسترد جميع الإشعارات للمستخدم الحالي، ويدمج البيانات المحلية وبيانات Firebase.
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final String userId = _firebaseService.currentUserId ?? '';
      if (userId.isEmpty) return [];

      // جلب الإشعارات من Firebase.
      final List<NotificationModel> firebaseNotifications =
      await _firebaseService.getUserNotifications();

      // جلب الإشعارات من قاعدة البيانات المحلية.
      final List<NotificationModel> localNotifications =
      await _databaseHelper.getUserNotifications(userId);

      final Map<String, NotificationModel> mergedNotifications = {};

      // ملء الخريطة بالإشعارات المحلية أولاً.
      for (final notification in localNotifications) {
        mergedNotifications[notification.id] = notification;
      }
      // الدمج مع إشعارات Firebase، مع إعطاء الأولوية لبيانات Firebase
      // ولكن مع الاحتفاظ بالبيانات المحلية فقط مثل thumbnailPath.
      for (final notification in firebaseNotifications) {
        final localNotification = mergedNotifications[notification.id];
        if (localNotification != null) {
          // إذا كانت موجودة محليًا، قم بالتحديث ببيانات Firebase ولكن احتفظ بالصورة المصغرة المحلية.
          mergedNotifications[notification.id] = notification.copyWith(
            thumbnailPath: localNotification.thumbnailPath,
          );
        } else {
          // إذا كانت موجودة فقط في Firebase، أضفها.
          mergedNotifications[notification.id] = notification;
        }

        // التأكد من أن الإشعار المدمج/Firebase موجود في قاعدة البيانات المحلية.
        // هذا يساعد في المزامنة وضمان الاتساق.
        await _databaseHelper.insertNotification(
          mergedNotifications[notification.id]!,
        );
      }

      // تحويل الخريطة إلى قائمة وفرزها حسب وقت الجدولة (الأحدث أولاً).
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