import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/main.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/views/current_groups/current_groups.dart';
import 'package:moment/views/feed/feed_page.dart';
import 'package:moment/views/profile/profile_page.dart';
import 'package:moment/views/test_page.dart';
import 'camera/camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  GlobalKey<CameraPageState> cameraKey = GlobalKey();
  int currentTab = 2;

  void changeCamera(String groupId) {
    cameraKey.currentState?.changeCamera(groupId);
    setState(() {
      currentTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: currentTab,
      animationDuration: const Duration(milliseconds: 500),
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const FeedPage(),
                CameraPage(key: cameraKey),
                ProfilePage(changeCamera: changeCamera,),
              ],
            ),
            Container(
              height: 90,
              color: const Color.fromRGBO(240, 240, 240, 0.9),
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: TabBar(
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.black,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      onTap: (tab) {
                        HapticFeedback.lightImpact();
                        setState(() {
                          currentTab = tab;
                        });
                      },
                      tabs: [
                        currentTab == 0 ? Tab(icon: Icon(Icons.people_alt, size: 24, color: AppColors.generateRandomContrastColor(Colors.white),), height: 80,) : const Tab(icon: Icon(Icons.people_alt_outlined, size: 24,), height: 80,),
                        currentTab == 1 ? Tab(icon: Icon(Icons.camera_alt, size: 30, color: AppColors.generateRandomContrastColor(Colors.white),), height: 80,) : const Tab(icon: Icon(Icons.camera_alt_outlined, size: 30,), height: 80,),
                        currentTab == 2 ? Tab(icon: Icon(Icons.person, size: 24, color: AppColors.generateRandomContrastColor(Colors.white),), height: 80, ) : const Tab(icon: Icon(Icons.person_outline, size: 24,), height: 80,)
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

