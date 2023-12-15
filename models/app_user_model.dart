

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moment/models/group_image_model.dart';

class AppUser {

  String? id;
  String? uid;
  String? phoneNumber;
  String? profilePic;
  String? username;
  String? displayName;
  List<GroupImage>? profileImages;
  String? bio;
  String? deviceToken;
  List<AppUser>? followers;
  List<AppUser>? following;

  AppUser({this.id, this.uid, this.phoneNumber, this.displayName, this.username, this.profilePic, this.profileImages, this.bio, this.deviceToken, this.followers, this.following});

  AppUser fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final document = snapshot.data();
    return AppUser(
      id: document?['id'],
      uid: document?['uid'],
      phoneNumber: document?['phoneNumber'],
      profilePic: document?['profilePic'],
      username: document?['username'],
      displayName: document?['displayName'],
      profileImages: document?['profileImages'] is Iterable ? List.from(document?['profileImages']).map((e) => GroupImage().fromMap(e)).toList() : null,
      bio: document?['bio'],
      deviceToken: document?['deviceToken'],
      followers: document?['followers'] is Iterable ? List.from(document?['followers']).map((e) => AppUser().fromMap(e)).toList() : null,
      following: document?['following'] is Iterable ? List.from(document?['following']).map((e) => AppUser().fromMap(e)).toList() : null,
    );
  }

  AppUser fromMap(Map<String, dynamic> document) {
    return AppUser(
      id: document['id'],
      uid: document['uid'],
      phoneNumber: document['phoneNumber'],
      profilePic: document['profilePic'],
      username: document['username'],
      displayName: document['displayName'],
      profileImages: document['profileImages'] is Iterable ? List.from(document['profileImages']).map((e) => GroupImage().fromMap(e)).toList() : null,
      bio: document['bio'],
      deviceToken: document['deviceToken'],
      following: document['following'] is Iterable ? List.from(document['following']).map((e) => AppUser().fromMap(e)).toList() : null,
      followers: document['followers'] is Iterable ? List.from(document['followers']).map((e) => AppUser().fromMap(e)).toList() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (uid != null) "uid": uid,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (displayName != null) "displayName": displayName,
      if (username != null) "username": username,
      if (profilePic != null) "profilePic": profilePic,
      if (profileImages != null) "profileImages": profileImages!.map((image) => image.toFirestore()).toList(),
      if (bio != null ) "bio" : bio,
      if (deviceToken != null) "deviceToken" : deviceToken,
      if (following != null) "following" : following!.map((e) => e.toFirestore()).toList(),
      if (followers != null) "followers" : followers!.map((e) => e.toFirestore()).toList(),
    };
  }

}