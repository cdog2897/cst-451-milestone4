import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import '../models/group_model.dart';
import 'dart:io';

class StorageService {

  static Future<String> uploadGroupImage(String filepath) async {
    final ref = FirebaseStorage.instance.ref("groupImages/${basename(filepath)}");
    try{
      await ref.putFile(File(filepath));
      filepath = await ref.getDownloadURL();
      return filepath;
    }
    catch (e) {
      print(e.toString());
      return '';
    }
  }

  static Future<String> uploadCameraImage(String filepath, Group group) async {
    final ref = FirebaseStorage.instance.ref("cameraImages/${group.groupId}/${basename(filepath)}");
    try {
      await ref.putFile(File(filepath));
      filepath = await ref.getDownloadURL();
      return filepath;
    }
    catch(e) {
      print(e.toString());
      return '';
    }
  }

}