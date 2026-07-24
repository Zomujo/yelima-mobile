import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/logger.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// Service responsible for handling application notifications.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  RemoteMessage? _initialMessage;
  RemoteMessage? get initialMessage => _initialMessage;
  bool isAppInitialized = false;

  Future<void> initialize() async {
    try {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
            handleMessageNavigation(message);
          }
        },
      );

      // Set foreground presentation options for iOS to show native banners
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // BACKGROUND listener
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (message.messageId != _initialMessage?.messageId) {
          handleMessageNavigation(message);
        }
      });

      // FOREGROUND (App is open and active)
      FirebaseMessaging.onMessage.listen(_showForegroundBanner);

      // COLD START / TERMINATED CHECK
      final fcmInitial = await _messaging.getInitialMessage();
      if (fcmInitial != null) {
        _initialMessage = fcmInitial;
      } else {
        final details =
            await _localNotifications.getNotificationAppLaunchDetails();

        if (details?.didNotificationLaunchApp ?? false) {
          final payload = details?.notificationResponse?.payload;
          if (payload != null) {
            _initialMessage = RemoteMessage.fromMap(jsonDecode(payload));
          }
        }
      }

      AppLogger.d('NotificationService: Initialized successfully');
    } catch (e, stack) {
      AppLogger.e('NotificationService: Failed to initialize', e, stack);
    }
  }

  Future<void> handleMessageNavigation(RemoteMessage? message) async {
    if (message == null) return;

    if (!isAppInitialized) {
      _initialMessage = message;
      return;
    }

    final data = getCleanData(message);
    AppLogger.i('NotificationService: Notification clicked with data: $data');

    _initialMessage = null;
  }

  Map<String, dynamic> getCleanData(RemoteMessage message) {
    if (message.data.containsKey('notification')) {
      var notificationField = message.data['notification'];

      if (notificationField is String) {
        notificationField = jsonDecode(notificationField);
      }

      if (notificationField is Map && notificationField.containsKey('data')) {
        return Map<String, dynamic>.from(notificationField['data']);
      }
    }
    return message.data;
  }

  Future<void> _showForegroundBanner(RemoteMessage message) async {
    final cleanData = getCleanData(message);

    final title = cleanData['title']?.toString() ??
        message.data['title']?.toString() ??
        message.notification?.title ??
        'Yelima';

    final body = cleanData['body']?.toString() ??
        message.data['body']?.toString() ??
        message.notification?.body ??
        '';

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android:
            AndroidNotificationDetails('high_importance_channel', 'General'),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      AppLogger.w(
          'NotificationService: Failed to subscribe to topic $topic: $e');
      rethrow;
    }
  }

  Future<void> unSubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      AppLogger.w(
          'NotificationService: Failed to unsubscribe from topic $topic: $e');
      rethrow;
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      AppLogger.i(
          'NotificationService: Scheduled daily reminder id=$id at ${time.hour}:${time.minute}');
    } catch (e, stack) {
      AppLogger.e('NotificationService: Failed to schedule reminder', e, stack);
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _localNotifications.cancel(id);
      AppLogger.i('NotificationService: Cancelled reminder id=$id');
    } catch (e, stack) {
      AppLogger.e(
          'NotificationService: Failed to cancel reminder $id', e, stack);
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _localNotifications.cancelAll();
      AppLogger.i('NotificationService: Cancelled all local reminders');
    } catch (e, stack) {
      AppLogger.e(
          'NotificationService: Failed to cancel all reminders', e, stack);
    }
  }

  Future<void> requestPermissions() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      AppLogger.i('NotificationService: Permissions requested successfully');
    } catch (e) {
      AppLogger.w('Error requesting notification permissions: $e');
    }
  }
}
