import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/trip_approval_one.dart';

import '../main.dart';

Future<void> showAlertDialog(BuildContext context, String title, String description, {bool isPop = true, VoidCallback? callBack}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: <Widget>[
          TextButton(
            child: const Text("Close"),
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
        title: const Text('Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (message.notification?.title != null)
              Text(message.notification!.title!),
            const SizedBox(height: 10),
            if (message.notification?.body != null)
              Text(message.notification!.body!),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              final tripId = message.data['tripId'] ?? message.data['tripID'] ?? message.data['trip_id'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripApprovalScreen(
                    tripID: tripId,
                  ),
                ),
              );
            },
          ),
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  ).then((value) {
    final id = message.notification?.hashCode ?? message.data.hashCode;
    flutterLocalNotificationsPlugin?.cancel(id: id);
  });
}
