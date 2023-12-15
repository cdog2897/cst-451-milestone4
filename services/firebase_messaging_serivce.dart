

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class MessagingService {


  static Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
    );

  }

  static Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if(token != null) {
      return token;
    }
    else {
      return null;
    }
  }


}