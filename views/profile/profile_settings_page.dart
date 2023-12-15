import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/main.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:path/path.dart';


class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account", style: TextStyle(color: Colors.black, fontSize: 24),),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          profile(context),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            child: const Text("Sign out"),
          )
        ],
      ),
    );
  }

  showEditProfile(BuildContext context) {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white
            ),
          );
        }
    );
  }

  Widget profile(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(currentUser.profilePic!)
                  )
              ),
            ),
            const SizedBox(width: 15,),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(currentUser.displayName!, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
                        const SizedBox(width: 10,),
                        Text(currentUser.username!, style: const TextStyle(color: Colors.black),),
                        const SizedBox(width: 10,),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            showEditProfile(context);
                          },
                          child: const Icon(Icons.edit_outlined, size: 18,),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    if(currentUser.bio != null) Row(
                      children: [
                        Flexible(
                          child: Text(currentUser.bio!, style: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 1.2),),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }


}
