import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/models/group_image_model.dart';
import 'package:moment/services/firestore_service.dart';

class IndividualPicturePage extends StatefulWidget {
  final GroupImage image;
  const IndividualPicturePage({super.key, required this.image});

  @override
  State<IndividualPicturePage> createState() => _IndividualPicturePageState();
}

class _IndividualPicturePageState extends State<IndividualPicturePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await FirestoreService.addImageToProfile(widget.image);
              },
              child: const Text("Add to profile"),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Image.network(widget.image.imgUrl!),
            ),
          ],
        ),
      )
    );
  }
}
