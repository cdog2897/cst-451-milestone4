import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/authentication/setup/setup_username_page.dart';
import 'package:moment/views/home_page.dart';
import 'package:path/path.dart';

import '../../main.dart';
import '../../models/group_model.dart';

class CheckIfUserRegisteredPage extends StatefulWidget {
  const CheckIfUserRegisteredPage({super.key});

  @override
  State<CheckIfUserRegisteredPage> createState() => _CheckIfUserRegisteredPageState();
}

class _CheckIfUserRegisteredPageState extends State<CheckIfUserRegisteredPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkIfUserRegistered() async {
    bool userRegistered = await FirestoreService.checkIfUserExists();
    if(userRegistered) {
      myGroups = await FirestoreService.getMyGroups();
      currentUser = await FirestoreService.getCurrentUser();
      return true;
    }
    else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkIfUserRegistered(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else {
          if(snapshot.data! == true) {
            return const HomePage();
          }
          else {
            return const SetupUsernamePage();
          }
        }
      },
    );
  }
}
