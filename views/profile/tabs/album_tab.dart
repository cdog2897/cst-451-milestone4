import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/views/camera/join_camera_page.dart';
import 'package:moment/views/profile/picture_page.dart';
import 'package:path/path.dart';

import '../../../main.dart';
import '../../../models/app_colors_model.dart';
import '../../../models/group_model.dart';
import '../../../services/firestore_service.dart';

class AlbumTab extends StatefulWidget {
  final Function changeCamera;
  const AlbumTab({super.key, required this.changeCamera});

  @override
  State<AlbumTab> createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab> {

  List<Group> pastGroups = [];
  List<Group> currentGroups = [];
  late Group individual;
  List<Group> unrevealedGroups = [];

  List<Color> colors = [];

  @override
  void initState() {
    for(var group in myGroups) {
      if(group.endDate!.isBefore(DateTime.now()) && !group.individual! && group.revealed!.contains(currentUser.uid!)) pastGroups.add(group);
      if(group.endDate!.isBefore(DateTime.now()) && !group.individual! && !group.revealed!.contains(currentUser.uid!)) unrevealedGroups.add(group);
      if(!group.individual! && group.endDate!.isAfter(DateTime.now())) {
        currentGroups.add(group);
      }
      if(group.individual!) individual = group;
    }
    int length = pastGroups.length + currentGroups.length + unrevealedGroups.length + 1;
    colors = AppColors.createGradient(length, AppColors.generateRandomContrastColor(Colors.black), AppColors.generateRandomContrastColor(Colors.black));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for(int i = 0; i < unrevealedGroups.length; i++) unrevealedGroup(context, unrevealedGroups[i], colors[i]),
        individualGroup(context, colors[unrevealedGroups.length]),
        for(int i = 0; i < currentGroups.length; i++) currentGroup(context, currentGroups[i], colors[i + 1 + unrevealedGroups.length]),
        for(int i = 0; i < pastGroups.length; i++) pastGroup(context, pastGroups[i], colors[i + 1 + unrevealedGroups.length + currentGroups.length]),
        const SizedBox(height: 50,)
      ],
    );
  }

  Widget pastGroup(BuildContext context, Group group, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color,
              // border: Border.all(color: Colors.black)
          ),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(group.imgUrl!)
                            )
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        children: [
                          Text(group.groupName!, style: const TextStyle(color: Colors.black, fontSize: 22, letterSpacing: 1.2, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PicturePage(group: group)));
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                  )
                ],
              )
          )
      ),
    );
  }

  Widget unrevealedGroup(BuildContext context, Group group, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: color,
                  border: Border.all(color: Colors.black)
              ),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 160,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(group.imgUrl!)
                                )
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            children: [
                              Text("${group.images!.length} photos are developed!", style: const TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          FirestoreService.updateRevealed(group);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PicturePage(group: group))).then((value) {
                            setState(() {
                            });
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      )
                    ],
                  )
              )
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          child: Container(
            width: double.maxFinite,
            height: 1,
            color: Colors.black,
          ),
        )
      ],
    );
  }

  Widget currentGroup(BuildContext context, Group group, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color,
              // border: Border.all(color: Colors.black)
          ),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(group.imgUrl!)
                            )
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Container(
                        height: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.groupName!, style: const TextStyle(color: Colors.black, fontSize: 22, letterSpacing: 1.2, fontWeight: FontWeight.bold),),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(group.endDate!.difference(DateTime.now()).inDays.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
                                const Text(" days ", style: TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 1.2),),
                                Text(group.endDate!.difference(DateTime.now()).inHours.remainder(24).toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
                                const Text(" hours ", style: TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 1.2),),
                                Text(group.endDate!.difference(DateTime.now()).inDays.remainder(60).toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),),
                                const Text(" mins ", style: TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 1.2),),
                              ],
                            ),
                            const SizedBox(height: 5,),
                            Text(
                              group.members!.length == 1 ? "${group.members!.length} member" : "${group.members!.length} members",
                              style: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 1),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // TODO: CAMERA INFORMATION CODE
                                  },
                                  icon: const Icon(Icons.ios_share),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // TODO: SETTINGS PAGE
                                  },
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.changeCamera(group.groupId!);
                      DefaultTabController.of(context).animateTo(1);
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 30,),
                  )
                ],
              )
          )
      ),
    );
  }

  Widget individualGroup(BuildContext context, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: color,
              // border: Border.all(color: Colors.black)
          ),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(individual.imgUrl!)
                            )
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text("${individual.groupName!}'s Camera", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.black),)
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.changeCamera(individual.groupId!);
                      DefaultTabController.of(context).animateTo(1);
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                  )
                ],
              )
          )
      ),
    );
  }
}
