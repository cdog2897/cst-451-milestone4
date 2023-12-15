import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertPopups {


  static Future<void> showAlertDialog(BuildContext context, String title, String content) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Ok"),
          )
        ],
      )
    );
  }

}