import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/trip_approval_one.dart';

import '../main.dart';

Future<void> showAlertDialog(BuildContext context, String title, String description, {bool isPop = true, VoidCallback? callBack}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("$title"),
        content: new Text("$description"),
        actions: <Widget>[
          new TextButton(
            child: new Text("Close"),
            onPressed: () {
              if (isPop) Navigator.of(context).pop();
              Navigator.of(context).pop();
              callBack?.call();
            },
          ),
        ],
      );
    },
  );
}

void showAlertDialogNotification(BuildContext context, RemoteMessage message) async {
  print(message.toString());
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text('Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("${message.notification?.title}"),
            const SizedBox(height: 10),
            new Text("${message.notification?.body}"),
          ],
        ),
        actions: <Widget>[
          new TextButton(
            child: new Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              final tripId = message.data['tripId'];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripApprovalScreen(
                      tripID: tripId,
                    ),
                  ));
            },
          ),
          new TextButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) {
    flutterLocalNotificationsPlugin?.cancel(message.notification.hashCode);
  });
}
