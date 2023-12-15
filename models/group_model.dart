

import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_image_model.dart';

class Group {
  DateTime? endDate;
  DateTime? expirationDate;
  String? code;
  String? groupId;
  String? groupName;
  String? imgUrl;
  bool? individual;
  List<String>? members;
  String? ownerId;
  DateTime? startDate;
  List<GroupImage>? images;
  List<String>? revealed;

  Group({this.imgUrl, this.members, this.ownerId, this.groupId, this.groupName, this.revealed, this.expirationDate, this.endDate, this.startDate, this.individual, this.images, this.code});

  Map<String, dynamic> toFirestore() {
    return {
      if (endDate != null) "endDate": endDate,
      if (code != null) "code" : code,
      if (expirationDate != null) "expirationDate": expirationDate,
      if (groupId != null) "groupId": groupId,
      if (groupName != null) "groupName": groupName,
      if (imgUrl != null) "imgUrl": imgUrl,
      if (individual != null) "individual": individual,
      if (members != null) "members": members,
      if (ownerId != null) "ownerId": ownerId,
      if (revealed != null) "revealed": revealed,
      if (startDate != null) "startDate": startDate,
      if (images != null) "images": images!.map((image) => image.toFirestore()).toList(),
    };
}

  Group fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final document = snapshot.data();

    return Group(
      endDate: document?['endDate']?.toDate(),
      expirationDate: document?['expirationDate']?.toDate(),
      groupId: document?['groupId'],
      groupName: document?['groupName'],
      imgUrl: document?['imgUrl'],
      individual: document?['individual'],
      members: document?['members'] is Iterable ? List.from(document?['members']) : null,
      ownerId: document?['ownerId'],
      revealed: document?['revealed'] is Iterable ? List.from(document?['revealed']) : null,
      startDate: document?['startDate']?.toDate(),
      images: document?['images'] is Iterable ? List.from(document?['images']).map((e) => GroupImage().fromMap(e)).toList() : null,
      code: document?['code']
    );
  }

}