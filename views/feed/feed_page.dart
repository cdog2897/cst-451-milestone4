import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moment/main.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/feed/inbox_page.dart';

import '../../models/post_model.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  late List<Post> myPosts;

  Future<List<Post>> getMyPosts() async {
    return await FirestoreService.getMyPosts();
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxPage()));
                },
                icon: const Icon(Icons.inbox_outlined, color: Colors.black,),
              ),
              Text("${currentUser.username}", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.black,),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: FutureBuilder(
          future: getMyPosts(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            else {
              myPosts = snapshot.data!;
              return RefreshIndicator(
                child: ListView.builder(
                  itemCount: myPosts.length,
                  itemBuilder: (context, index) {
                    return post(myPosts, index);
                  },
                ),
                onRefresh: () async {
                  setState(() {});
                },
              );
            }
          },
        )
      ),
    );
  }

  Widget post(List<Post> myPosts, int index) {
    String formattedTime = DateFormat('h:mm a').format(myPosts[index].captured!).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3/4,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                image: DecorationImage(
                    image: NetworkImage(myPosts[index].imgUrl!),
                    fit: BoxFit.cover
                ),
                color: Colors.white
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            0,
                            0.1
                          ],
                          colors: [
                            Colors.black38,
                            Colors.transparent
                          ]
                      ),
                      borderRadius: BorderRadius.circular(2)
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(myPosts[index].groupName!, style: TextStyle(color: AppColors.text, fontSize: 18, letterSpacing: 1),),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Text(formattedTime, style: TextStyle(color: AppColors.text, fontSize: 18),),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Text(myPosts[index].ownerUsername!, style: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 1),),
        const SizedBox(height: 30,)
      ],
    );
  }

}
