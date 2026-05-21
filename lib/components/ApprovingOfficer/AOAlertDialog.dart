import 'package:flutter/material.dart';

Future<void> showAOAlertDialog(BuildContext context, String title, String description, {bool popAll = false}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              if (popAll) {
                while (Navigator.of(context).canPop()) { Navigator.of(context).pop(); }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
