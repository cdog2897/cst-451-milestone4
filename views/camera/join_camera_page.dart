import 'package:flutter/material.dart';
import 'package:moment/services/firestore_service.dart';

import '../../models/group_model.dart';

class JoinCameraPage extends StatefulWidget {
  final Group group;
  const JoinCameraPage({super.key, required this.group});

  @override
  State<JoinCameraPage> createState() => _JoinCameraPageState();
}

class _JoinCameraPageState extends State<JoinCameraPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName!),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.group.imgUrl!)
                )
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirestoreService.joinGroup(widget.group);
              },
              child: const Text("Join Gorup"),
            )
          ],
        ),
      ),
    );
  }
}
