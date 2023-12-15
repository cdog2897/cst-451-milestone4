import 'package:flutter/material.dart';

import '../../../models/app_colors_model.dart';
import '../../../models/post_model.dart';
import '../../../services/firestore_service.dart';

class PictureTab extends StatefulWidget {
  const PictureTab({super.key});

  @override
  State<PictureTab> createState() => _PictureTabState();
}

class _PictureTabState extends State<PictureTab> {



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService.getMyPosts(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        else {
          List<Post> profileImages = snapshot.data!;
          if(profileImages.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Center(
                child: Text("You have no images in your profile", style: TextStyle(color: AppColors.text),),
              ),
            );
          }
          int numRows = (profileImages.length / 3).ceil();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for(int i = 0; i < numRows; i++) Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for(int j = 0; j < 3; j++) Flexible(
                        child: AspectRatio(
                            aspectRatio: 4/5,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: profileImages.length > ((i)*3) + j ? FadeInImage.assetNetwork(placeholder: "assets/images/loading.gif", image: profileImages[((i)*3) + j].imgUrl!, fit: BoxFit.cover) : Container(),
                            )
                        ),
                      )
                    ]
                )
              ]
          );
        }
      },
    );
  }
}
