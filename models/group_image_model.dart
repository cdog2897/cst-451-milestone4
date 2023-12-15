

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupImage {

  String? localImgPath;
  String? imgUrl;
  String? ownerId;
  DateTime? dateTimeTaken;
  String? groupName;

  GroupImage({this.imgUrl, this.ownerId, this.dateTimeTaken, this.localImgPath, this.groupName});

  Map<String, dynamic> toFirestore() {
    return {
      if (imgUrl != null) "imgUrl": imgUrl,
      if (localImgPath != null) "localImgPath": localImgPath,
      if (ownerId != null) "ownerId": ownerId,
      if (dateTimeTaken != null) "dateTimeTaken": dateTimeTaken,
      if (groupName != null) "groupName": groupName,
    };
  }

  GroupImage fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final document = snapshot.data();
    return GroupImage(
      imgUrl: document?['imgUrl'],
      localImgPath: document?['localImgPath'],
      ownerId: document?['ownerId'],
      groupName: document?['groupName'],
      dateTimeTaken: document?['dateTimeTaken'].toDate()
    );
  }

  GroupImage fromMap(Map<String, dynamic> map) {
    return GroupImage(
      imgUrl: map['imgUrl'],
      localImgPath: map['localImgPath'],
      ownerId: map['ownerId'],
      groupName: map['groupName'],
      dateTimeTaken: map['dateTimeTaken'].toDate(),
    );
  }

}