import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/profile/tabs/picture_tab.dart';

import '../../models/app_user_model.dart';


class IndividualProfilePage extends StatefulWidget {
  final String uid;
  const IndividualProfilePage({super.key, required this.uid});

  @override
  State<IndividualProfilePage> createState() => _IndividualProfilePageState();
}

class _IndividualProfilePageState extends State<IndividualProfilePage> {

  AppUser user = AppUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService.getUserByUid(widget.uid),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        else {
          user = snapshot.data!;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text(user.username!, style: TextStyle(color: Colors.black),),
            ),
            body: ListView(
              children: [
                const SizedBox(height: 20,),
                profile(),
                const PictureTab()
              ],
            ),
          );
        }
      },
    );
  }
  
  Widget profile() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10,),
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.displayName!, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
                      const SizedBox(width: 10,),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  if(user.bio != null) Row(
                    children: [
                      Flexible(
                        child: Text(user.bio!, style: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 1.2),),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15,),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(user.profilePic!)
                )
            ),
          ),
        ],
      ),
    );
  }
  
}
