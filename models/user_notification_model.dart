

import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {

  String? imgUrl;
  String? title;
  String? description;
  String? deviceToken;
  String? uid;

  UserNotification({this.imgUrl, this.description, this.title, this.deviceToken, this.uid});

  UserNotification fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final document = snapshot.data();
    return UserNotification(
      imgUrl: document?['imgUrl'],
      title: document?['title'],
      description: document?['description'],
      deviceToken: document?['deviceToken'],
      uid: document?['uid']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (imgUrl != null) "imgUrl" : imgUrl,
      if (title != null) "title" : title,
      if (description != null) "description" : description,
      if (deviceToken !=null) "deviceToken" : deviceToken,
      if (uid != null) "uid" : uid
    };
  }

}