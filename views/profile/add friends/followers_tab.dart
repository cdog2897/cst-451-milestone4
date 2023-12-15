import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../models/app_colors_model.dart';
import '../../../models/app_user_model.dart';
import '../../../services/firestore_service.dart';
import '../individual_profile_page.dart';

class FollowersTab extends StatefulWidget {
  const FollowersTab({super.key});

  @override
  State<FollowersTab> createState() => _FollowersTabState();
}

class _FollowersTabState extends State<FollowersTab> {
  List<AppUser> users = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirestoreService.getFollowers(),
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
    int status = 1;
    if(currentUser.following != null && currentUser.following!.isNotEmpty) {
      if(currentUser.following!.where((appUser) => appUser.uid! == user.uid!).firstOrNull != null) status = 0;
    }

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
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white),
                                  color: Color.fromRGBO(255, 255, 255, 0.6)
                              ),
                              child: const Center(
                                child: Text("Following", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
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
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white),
                                  color: const Color.fromRGBO(255, 255, 255, 0.6)
                              ),
                              child: const Center(
                                  child: Text("Follow", style: TextStyle(fontSize: 18),)
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
