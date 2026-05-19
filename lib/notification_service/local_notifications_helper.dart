import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_helper.dart';

/// Local notification helper class
class LocalNotificationHelper {
  LocalNotificationHelper._();

  /// instance of LocalNotificationHelper
  static final localNotificationHelper = LocalNotificationHelper._();

  /// FlutterLocalNotificationsPlugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// android channel
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    importance: Importance.high,
  );

  /// android initialization
  static const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  /// ios initialization
  static const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

  /// Android Notification Details
  static AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    visibility: NotificationVisibility.public,
    importance: Importance.high,
    enableLights: true,
  );

  /// iOS Notification Details
  static DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(presentSound: true);

  /// initialize
  Future<void> initialize() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    // await iZooto.setSubscription(true);
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin),

      onDidReceiveNotificationResponse: (details) {
        NotificationHelper.notificationOnTapHandler(localData: details, isLocal: true);
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// show Notification
  Future<void> showNotification(RemoteMessage remoteMessage) async {
    await flutterLocalNotificationsPlugin.show(
       remoteMessage.notification.hashCode,
       remoteMessage.notification?.title,
      remoteMessage.notification?.body,
      payload: remoteMessage.data.isNotEmpty ? jsonEncode(remoteMessage.data) : null,
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      ),
    );
  }
}
