import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:moment/services/firebase_messaging_serivce.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Coleoptera_collage.png/1258px-Coleoptera_collage.png"),
                fit: BoxFit.cover
              )
            ),
          ),
          ElevatedButton(
           onPressed: () async {
           },
            child: Text("join camera"),
          )
        ],
      )
    );
  }
}
