import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/profile/individual_profile_page.dart';

import '../../main.dart';
import '../../models/app_colors_model.dart';
import '../../models/user_notification_model.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int length = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: FirestoreService.getMyNotifications(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          else {
            List<UserNotification> notifications = [];
            if(snapshot.data != null) notifications = snapshot.data!;
            length = notifications.length;

            List<Color> colors = AppColors.createGradient(length, AppColors.generateRandomContrastColor(Colors.black), AppColors.generateRandomContrastColor(Colors.black));

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return notificationContainer(notifications[index], colors[index]);
              },
            );
          }
        },
      ),
    );
  }


  Widget notificationContainer(UserNotification notification, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          border: Border.all(color: color, width: 2)
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualProfilePage(uid: notification.uid!,)));
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(notification.imgUrl!)
                      )
                  ),
                ),
              ),
              const SizedBox(width: 15,),
              Text(notification.description!, style: const TextStyle(color: Colors.black, fontSize: 16),),
            ],
          ),
        )
      ),
    );
  }


}
