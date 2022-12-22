import 'dart:convert';

import 'package:blog_app/models/notification/notification.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/user_controller.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future showNotificationWithDefaultSound(RemoteMessage message) async {
  // NotificationResponse notificationResponse = NotificationResponse.fromJsonMap(jsonDecode(jsonEncode(message.notification?.body)));
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'your channel id 123',
    'your channel name 123',
    channelDescription: 'your channel description 123',
    color: Color(0xff203E78),
    importance: Importance.max,
    icon: "logo",
    priority: Priority.high,
    playSound: true,
  );
  var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  if (flutterLocalNotificationsPlugin != null) {
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title != null
          ? message.notification?.title
          : "New Notification",
      message.notification?.body != null ? message.notification?.body : "",
      platformChannelSpecifics,
      payload: message.data == null ? 'null' : message.data['id'].toString(),
    );
  }
}

Future notificationOnMessage(Map<String, dynamic> message) async {
  print("notificationOnMessage $message");
}
