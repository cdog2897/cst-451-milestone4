import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/views/profile/add%20friends/all_users_tab.dart';
import 'package:moment/views/profile/add%20friends/followers_tab.dart';
import 'package:moment/views/profile/add%20friends/following_tab.dart';

import '../tabs/album_tab.dart';
import '../tabs/picture_tab.dart';

class AddFriendsPage2 extends StatefulWidget {
  const AddFriendsPage2({super.key});

  @override
  State<AddFriendsPage2> createState() => _AddFriendsPage2State();
}

class _AddFriendsPage2State extends State<AddFriendsPage2> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _tabController.index = 0;
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if(_tabController.indexIsChanging) {
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Add Friends", style: TextStyle(color: Colors.black),),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            searchBar(),
            const SizedBox(height: 10,),
            tabBar(),
            Center(
              child: [
                const FollowingTab(),
                const FollowersTab(),
                const AllUsersTab(),
              ][_tabController.index],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return Container(
      width: double.maxFinite,
      height: 30,
      color: AppColors.generateRandomContrastColor(Colors.black),
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
        Tab(child: Text("following", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: _tabController.index == 0 ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),),
        Tab(child: Text("followers", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: _tabController.index == 1 ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2)),),
        Tab(child: Text("all users", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: _tabController.index == 2 ? FontWeight.bold : FontWeight.normal, letterSpacing: 1.2),),)
      ],
    );
  }


}
