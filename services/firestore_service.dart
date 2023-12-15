import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moment/main.dart';
import 'package:moment/models/group_image_model.dart';
import 'package:moment/models/user_notification_model.dart';
import 'package:moment/services/firebase_messaging_serivce.dart';
import 'package:path/path.dart';
import '../models/app_user_model.dart';
import '../models/group_model.dart';
import '../models/post_model.dart';

class FirestoreService {

  // USER
  static Future<AppUser> getUserByUid(String uid) async{
    AppUser user = AppUser();
    final db = FirebaseFirestore.instance;
    await db.collection('users').where('uid', isEqualTo: uid).get().then((snapshot) {
      user = AppUser().fromFirestore(snapshot.docs.first);
    });
    return user;
  }

  static Future<List<AppUser>> searchAllUsers(String input) async {
    List<AppUser> users = [];
    input = input.toLowerCase().trim();
    if(input.isEmpty) {
      return users;
    }
    final db = FirebaseFirestore.instance;
    await db.collection('users').where('username', isGreaterThanOrEqualTo: input).where('username', isLessThan: '${input}z').limit(8).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        users.add(AppUser().fromFirestore(doc));
      }
    });
    return users;
  }

  static Future<void> followUser(AppUser user) async {
    // if duplicate follow, ignore:
    if(currentUser.following != null && currentUser.following!.isNotEmpty) {
      if(currentUser.following!.where((appUser) => appUser.uid! == user.uid!).firstOrNull != null) {
        return;
      }
    }

    currentUser.following ??= [];
    currentUser.following!.add(AppUser(uid: user.uid!, displayName: user.displayName!, username: user.username!, profilePic: user.profilePic!, id: user.id));

    user.followers ??= [];
    user.followers!.add(AppUser(uid: currentUser.uid, displayName: currentUser.displayName, username: currentUser.username, profilePic: currentUser.profilePic, id: currentUser.id));

    final db = FirebaseFirestore.instance;
    await db.collection('users').doc(currentUser.id).update({
      "following" : currentUser.following!.map((e) => e.toFirestore()).toList()
    });
    await db.collection('users').doc(user.id).update({
      "followers" : user.followers!.map((e) => e.toFirestore()).toList()
    });

    //send notification:
    UserNotification notification = UserNotification(
      imgUrl: currentUser.profilePic,
      title: "you have a new follower",
      description: "${currentUser.displayName} started following you",
      deviceToken: currentUser.deviceToken,
      uid: currentUser.uid
    );
    await db.collection('users').doc(user.id).collection('notifications').add(notification.toFirestore());
  }

  static Future<void> unfollowUser(AppUser user) async {
    List<AppUser> following = [];
    if(currentUser.following != null && currentUser.following!.isNotEmpty) following = currentUser.following!;
    following.removeWhere((appUser) => appUser.uid! == user.uid!);

    List<AppUser> followers = [];
    if(user.followers != null && user.followers!.isNotEmpty) followers = user.followers!;
    followers.removeWhere((appUser) => appUser.uid! == currentUser.uid!);

    final db = FirebaseFirestore.instance;
    await db.collection('users').doc(currentUser.id).update({
      "following" : following.map((e) => e.toFirestore()).toList()
    });

    await db.collection('users').doc(user.id).update({
      "followers" : followers.map((e) => e.toFirestore()).toList()
    });

  }

  static Future<void> requestToFollow(AppUser user) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('users').doc(user.id).collection('friendRequests').doc(currentUser.id);
    await ref.set({
      "requestFrom" : currentUser.toFirestore(),
      "requestTo" : user.toFirestore(),
    });

    UserNotification notification = UserNotification(
        imgUrl: currentUser.profilePic!,
        description: "${currentUser.displayName!} has requested to be friends 🥹",
        title: "You have a new friend request!",
        deviceToken: user.deviceToken!,
        uid: currentUser.uid
    );

    await db.collection('users').doc(user.id).collection('notifications').add(notification.toFirestore());
  }

  static Future<List<AppUser>> getAllUsers() async {
    final db = FirebaseFirestore.instance;
    List<AppUser> users = [];
    await db.collection('users').get().then((snapshot) {
      for(var doc in snapshot.docs) {
        users.add(AppUser().fromFirestore(doc));
      }
    });
    return users;
  }

  static Future<void> ignoreFriendRequest(AppUser user) async {
    // final db = FirebaseFirestore.instance;
    //
    // // remove friend request from currentUser
    // List<String> followRequests = currentUser.followRequests!;
    // followRequests.removeWhere((friend) => friend == user.uid!);
    // await db.collection('users').doc(currentUser.id).update({
    //   "followRequests" : followRequests
    // });
  }

  static Future<void> acceptFollowRequest(AppUser user) async {
    final db = FirebaseFirestore.instance;

    final refCurrentUser = db.collection('users').doc(currentUser.id).collection('friends').doc(user.id);
    await refCurrentUser.set({
      "uid" : user.uid,
      "deviceToken" : user.deviceToken,
      "displayName" : user.displayName,
      "profilePic" : user.profilePic,
      "id" : user.id
    });

    final refUser = db.collection('users').doc(user.id).collection('friends').doc(currentUser.id);
    await refUser.set({
      "uid" : currentUser.uid,
      "deviceToken" : currentUser.deviceToken,
      "displayName" : currentUser.displayName,
      "profilePic" : currentUser.profilePic,
      "id" : currentUser.id
    });

    await db.collection('users').doc(currentUser.id).collection('friendRequests').doc(user.id).delete();

  }

  static Future<List<AppUser>> getFollowRequests() async {
    List<AppUser> users = [];
    final db = FirebaseFirestore.instance;
    await db.collection('users').doc(currentUser.id).collection('friendRequests').get().then((snapshot) {
      for(var doc in snapshot.docs) {
        users.add(AppUser().fromMap(doc["requestFrom"]));
      }
    });
    return users;
  }

  static Future<bool> checkIfUserExists() async {
    bool doesExist = false;
    final db = FirebaseFirestore.instance;
    await db.collection('users').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        doesExist = true;
      }
    });
    return doesExist;
  }

  static Future<bool> checkIfUsernameUnique(String username) async {
    bool isUnique = true;
    final db = FirebaseFirestore.instance;
    await db.collection('users').where('username', isEqualTo: username).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        isUnique = false;
      }
    });
    return isUnique;
  }

  static Future<void> createUser(String username) async {
    final db = FirebaseFirestore.instance;

    // ask for permission for notifications:
    await MessagingService.requestPermission();
    String? token = await MessagingService.getToken();

    // create appuser
    final userRef = db.collection('users').doc();
    AppUser user = AppUser(
        id: userRef.id,
        uid: FirebaseAuth.instance.currentUser!.uid,
        phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber,
        username: username,
        displayName: username,
        profilePic: "https://firebasestorage.googleapis.com/v0/b/dispo-app-449bd.appspot.com/o/profile_pictures%2Fimage_picker_6798F16A-6B54-4F64-947A-9C9A5B4B8DE9-3120-00000770944C41DE.jpg?alt=media&token=b04e95b8-cd40-4b97-a68c-34852386b4cd",
        deviceToken: token
    );
    await userRef.set(user.toFirestore());

    // create individual group
    final ref = db.collection('groups').doc();
    Group group = Group(
        groupName: user.username,
        imgUrl: user.profilePic,
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        groupId: ref.id,
        members: [FirebaseAuth.instance.currentUser!.uid],
        individual: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7))
    );
    await ref.set(group.toFirestore());

  }

  static Future<AppUser> getCurrentUser() async {
    AppUser user = AppUser();
    final db = FirebaseFirestore.instance;
    await db.collection('users').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        user = AppUser().fromFirestore(doc);
      }
    });
    return user;
  }

  static Future<List<AppUser>> getFollowing() async {
    final db = FirebaseFirestore.instance;
    List<AppUser> users = [];
    await db.collection('users').where('uid', isEqualTo: currentUser.uid!).get().then((snapshot) {
      AppUser user = AppUser().fromFirestore(snapshot.docs.first);
      for(var u in user.following!) {
        users.add(u);
      }
    });
    return users;
  }

  static Future<List<AppUser>> getFollowers() async {
    final db = FirebaseFirestore.instance;
    List<AppUser> users = [];
    await db.collection('users').where('uid', isEqualTo: currentUser.uid!).get().then((snapshot) {
      AppUser user = AppUser().fromFirestore(snapshot.docs.first);
      for(var u in user.followers!) {
        users.add(u);
      }
    });
    return users;
  }



  // GROUP
  static Future<void> joinGroup(Group group) async {
    List<String> members = group.members!;
    members.add(FirebaseAuth.instance.currentUser!.uid);
    final db = FirebaseFirestore.instance;
    await db.collection('groups').doc(group.groupId).update({
      "members" : members
    });
  }

  static Future<Map<bool, Group>> groupExists(String pin) async {
    bool doesExist = false;
    Group group = Group();
    final db = FirebaseFirestore.instance;
    await db.collection('groups').where('code', isEqualTo: pin).get().then((snapshot) {
      if(snapshot.docs.isNotEmpty) {
        doesExist = true;
        group = Group().fromFirestore(snapshot.docs.first);
      }
    });
    Map<bool, Group> map = {doesExist: group};
    return map;
  }

  static Future<void> updateRevealed(Group group) async {
    final db = FirebaseFirestore.instance;
    List<String> members = [];
    if(group.revealed != null) members = group.revealed!;
    members.add(currentUser.uid!);
    await db.collection('groups').doc(group.groupId).update({
      "revealed" : members
    });
  }

  static Future<void> createGroup(Group group) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('groups').doc();
    group.code = await createCode();
    group.groupId = ref.id;
    group.members = [FirebaseAuth.instance.currentUser!.uid];
    group.ownerId = FirebaseAuth.instance.currentUser!.uid;
    group.individual = false;
    group.startDate = DateTime.now();
    group.endDate = group.startDate!.add(const Duration(days: 7));
    group.revealed = [];
    await ref.set(group.toFirestore());
    myGroups.add(group);
  }

  static Future<List<Group>> getMyGroups() async {
    List<Group> groups = [];
    final db = FirebaseFirestore.instance;
    await db.collection('groups')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get().then((snapshot) {
      for(var doc in snapshot.docs) {
        Group group = Group().fromFirestore(doc);
        groups.add(group);
      }
    });
    return groups;
  }

  static Future<String> createCode() async {
    Random random = Random();
    int codeInt = random.nextInt(8999) + 1000;
    String code = codeInt.toString();
    // check if code is available:
    bool isAvailable = false;
    final db = FirebaseFirestore.instance;
    await db.collection('groups').where('code', isEqualTo: code).get().then((snapshot) {
      if(snapshot.docs.isEmpty) {
        isAvailable = true;
      }
      else {
        for(var doc in snapshot.docs) {
          Group group = Group().fromFirestore(doc);
          if(group.endDate!.isAfter(DateTime.now())) {
            isAvailable = false;
            break;
          }
        }
      }
    });
    if(isAvailable) return code;
    code = await createCode();
    return code;
  }

  static Future<void> addImageToGroup(GroupImage image, Group group) async {
    Group updatedGroup = myGroups.firstWhere((thisGroup) => thisGroup.groupId == group.groupId);
    updatedGroup.images == null ? updatedGroup.images = [image] : updatedGroup.images!.add(image);
    final db = FirebaseFirestore.instance;
    await db.collection('groups').doc(group.groupId).update({
      "images" : updatedGroup.images!.map((image) => image.toFirestore()).toList()
    });
    // TODO: update myGroups
  }




  // NOTIFICATIONS
  static Future<List<UserNotification>> getMyNotifications() async {
    final db = FirebaseFirestore.instance;
    List<UserNotification> notifications = [];
    await db.collection('users').doc(currentUser.id).collection('notifications').get().then((snapshot) {
      for(var doc in snapshot.docs) {
        notifications.add(UserNotification().fromFirestore(doc));
      }
    });
    return notifications;
  }


  // POSTS
  static Future<List<Post>> getMyPosts() async {
    List<Post> posts = [];
    final db = FirebaseFirestore.instance;
    await db.collection('posts').where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).orderBy('posted', descending: true).limit(50).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        posts.add(Post().fromFirestore(doc));
      }
    });
    return posts;
  }

  static Future<List<Post>> getMyFeed() async {
    List<Post> posts = [];
    final db = FirebaseFirestore.instance;
    await db.collection('posts').where('ownerId', whereIn: currentUser.following).orderBy('posted', descending: true).get().then((snapshot) {
      for(var doc in snapshot.docs) {
        posts.add(Post().fromFirestore(doc));
      }
    });
    return posts;
  }

  static Future<void> addImageToProfile(GroupImage image) async {
    final db = FirebaseFirestore.instance;
    Post post = Post(
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      imgUrl: image.imgUrl,
      posted: DateTime.now(),
      captured: image.dateTimeTaken,
      ownerUsername: currentUser.username,
      groupName: image.groupName
    );
    final ref = db.collection('posts').doc();
    await ref.set(post.toFirestore());
  }


}