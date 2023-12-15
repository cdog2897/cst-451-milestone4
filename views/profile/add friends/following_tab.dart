import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/profile/individual_profile_page.dart';

import '../../../main.dart';
import '../../../models/app_user_model.dart';

class FollowingTab extends StatefulWidget {
  const FollowingTab({super.key});

  @override
  State<FollowingTab> createState() => _FollowingTabState();
}

class _FollowingTabState extends State<FollowingTab> {

  List<AppUser> users = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService.getFollowing(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        else {
          if(snapshot.data != null) users = snapshot.data!;
          List<Color> colors = AppColors.createGradient(users.length, AppColors.generateRandomContrastColor(Colors.black), AppColors.generateRandomContrastColor(Colors.black));
          return Padding(
            padding: const EdgeInsets.all(10),
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
    int status = 0;

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
              color: Colors.white,
              border: Border.all(color: color, width: 2.5)
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
                StatefulBuilder(
                  builder: (context, setWidgetState) {
                    if(status == 0) {
                      return InkWell(
                        onTap: () {
                          FirestoreService.unfollowUser(user);
                          setWidgetState((){
                            status = 1;
                          });
                        },
                        child: Container(
                            width: 80,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text("Following", style: TextStyle(fontSize: 18),),
                            )
                        ),
                      );
                    }
                    else {
                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          FirestoreService.followUser(user);
                          setWidgetState((){
                            status = 0;
                          });
                        },
                        child: Container(
                            width: 80,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: color.withOpacity(0.5), width: 2),
                              color: color.withOpacity(0.2)
                            ),
                            child: const Center(
                              child: Text("Follow", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                            )
                        ),
                      );
                    }
                  },
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
