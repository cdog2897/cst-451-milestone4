


import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  String? ownerId;
  String? imgUrl;
  DateTime? posted;
  DateTime? captured;
  String? ownerUsername;
  String? groupName;

  Post({this.imgUrl, this.ownerId, this.captured, this.posted, this.ownerUsername, this.groupName});

  Map<String, dynamic> toFirestore() {
    return {
      if (ownerId != null) "ownerId": ownerId,
      if (imgUrl != null) "imgUrl": imgUrl,
      if (posted != null) "posted": posted,
      if (captured != null) "captured": captured,
      if (ownerUsername != null) "ownerUsername": ownerUsername,
      if (groupName != null) "groupName": groupName,
    };
  }

  Post fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final document = snapshot.data();
    return Post(
      ownerId: document?['ownerId'],
      imgUrl: document?['imgUrl'],
      posted: document?['posted'].toDate(),
      captured: document?['captured'].toDate(),
      ownerUsername: document?['ownerUsername'],
      groupName: document?['groupName'],
    );
  }


}