import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/main.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/camera/create_new_camera_bottomsheet.dart';
import 'package:moment/views/current_groups/current_groups.dart';
import 'package:moment/views/profile/tabs/album_tab.dart';
import 'package:moment/views/profile/picture_page.dart';
import 'package:moment/views/profile/tabs/picture_tab.dart';
import 'package:moment/views/profile/profile_settings_page.dart';
import '../../models/app_colors_model.dart';
import '../../models/group_model.dart';
import '../../models/post_model.dart';
import 'add friends/add_friends_page_2.dart';

class ProfilePage extends StatefulWidget {
  final Function changeCamera;
  const ProfilePage({super.key, required this.changeCamera});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _tabController.index = 1;
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(35),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettings()));
                  },
                  icon: const Icon(Icons.more_horiz_outlined, color: Colors.black,),
                ),
                Text("${currentUser.username}", style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFriendsPage2()));
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.black,),
                )
              ]
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            myGroups = await FirestoreService.getMyGroups();
            setState(() {});
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: profile(),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tabBar(),
                  Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          CreateNewCameraBottomSheet(context: context).createGroupBottomSheet();
                        },
                        child: const Icon(Icons.add),
                      )
                  )
                ],
              ),
              const SizedBox(height: 10,),
              Center(
                child: [
                  const PictureTab(),
                  AlbumTab(changeCamera: widget.changeCamera, key: ValueKey(myGroups),)
                ][_tabController.index],
              ),
            ],
          ),
        )
    );
  }

  Widget tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.text,
      indicatorColor: AppColors.generateRandomContrastColor(Colors.black),
      splashFactory: NoSplash.splashFactory,
      overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.only(bottom: 8),
      onTap: (_) {
        HapticFeedback.lightImpact();
      },
      tabs: [
        Tab(child: Text("profile", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: _tabController.index == 0 ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),),
        Tab(child: Text("moments", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: _tabController.index == 1 ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),),
      ],
    );
  }

  Widget topRow() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("@${currentUser.username}", style: TextStyle(color: AppColors.text),)
        ],
      ),
    );
  }

  Widget profile() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10,),
        Expanded(
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(currentUser.displayName!, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
                    const SizedBox(width: 10,),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.changeCamera(myGroups.where((element) => element.individual == true).first.groupId);
                        DefaultTabController.of(context).animateTo(1);
                      },
                      child: const Icon(Icons.camera_alt_outlined),
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
        const SizedBox(width: 15,),
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
      ],
    );
  }

  Widget pastGroupRevealed(Group group) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        width: double.maxFinite,
        height: 140,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.background
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(group.imgUrl!)
                    )
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(group.groupName!, style: TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.bold),),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(group.imgUrl!)
                            )
                        ),
                      ),
                      const SizedBox(width: 3,),
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(group.imgUrl!)
                            )
                        ),
                      ),
                      const SizedBox(width: 3,),
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(group.imgUrl!)
                            )
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Icon(Icons.photo_album_outlined, color: AppColors.text,),
                  Icon(Icons.arrow_forward_ios, color: AppColors.text,)
                ],
              )
            ],
          ),
        )
      ),
    );
  }

}
