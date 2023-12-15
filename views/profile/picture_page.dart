import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_colors_model.dart';
import '../../models/group_model.dart';
import 'individual_picture_page.dart';

class PicturePage extends StatefulWidget {
  final Group group;
  const PicturePage({super.key, required this.group});

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Photos"),
      ),
      body: ListView(
        children: [
          pictureView()
        ],
      )
    );
  }

  Widget pictureView() {

    if(widget.group.images == null) {
      return Container(
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Text("You have no images in your group", style: TextStyle(color: AppColors.text),),
        ),
      );
    }

    int numRows = (widget.group.images!.length / 3).ceil();
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
                        child: widget.group.images!.length > ((i)*3) + j
                            ? InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => IndividualPicturePage(image: widget.group.images![((i)*3) + j]),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero
                            ));
                          },
                          child: Image.network(widget.group.images![((i)*3) + j].imgUrl!, fit: BoxFit.cover)
                        )
                            : Container(),
                      )
                  ),
                )
              ]
          )
        ]
    );
  }

}
