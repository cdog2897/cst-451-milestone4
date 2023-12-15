import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:moment/firebase_options.dart';
import 'package:moment/views/landing_page.dart';

import 'models/app_user_model.dart';
import 'models/group_model.dart';

late List<CameraDescription> cameras;
late List<Group> myGroups;
late AppUser currentUser;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.onMessage.listen((message) {
    print("message recieved: ${message.data}");
    if(message.notification != null) {
      print("message: ${message.notification!.body}");
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
      MaterialApp(
      theme: ThemeData(fontFamily: 'Helvetica'),
      home: const LandingPage(),
    )
  );
}