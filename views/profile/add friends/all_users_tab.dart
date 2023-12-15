import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/profile/individual_profile_page.dart';

import '../../../main.dart';
import '../../../models/app_user_model.dart';

class AllUsersTab extends StatefulWidget {
  const AllUsersTab({super.key});

  @override
  State<AllUsersTab> createState() => _AllUsersTabState();
}

class _AllUsersTabState extends State<AllUsersTab> {

  List<AppUser> users = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          else {
            if(snapshot.data != null) users = snapshot.data!;
            List<Color> colors = AppColors.createGradient(users.length, AppColors.generateRandomContrastColor(Colors.black), AppColors.generateRandomContrastColor(Colors.black));
            return Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    for(int i = 0; i < users.length; i++) userContainer(users[i], colors[i])
                  ],
                )
            );

          }
        }
    );
  }

  Widget userContainer(AppUser user, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualProfilePage(uid: user.uid!)));
        },
        child: Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: color
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(user.profilePic!)
                        )
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(user.displayName!),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      FirestoreService.followUser(user);
                    },
                    child: Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                            color: Color.fromRGBO(255, 255, 255, 0.6)
                        ),
                        child: Center(
                          child: currentUser.following != null && currentUser.following!.contains(user.uid!) ? Text("Following") : Text("Follow"),
                        )
                    ),
                  ),
                  const SizedBox(width: 15,)
                ],
              ),
            )
        ),
      ),
    );
  }


}
