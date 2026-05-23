import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/ApprovedTrip.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/PendingTrip.dart';
import 'package:transport_flutter/util/currentUserData.dart';

class ApprovingOfficerHome extends StatefulWidget {
  const ApprovingOfficerHome({Key? key}) : super(key: key);

  @override
  _ApprovingOfficerHomeState createState() => _ApprovingOfficerHomeState();
}

class _ApprovingOfficerHomeState extends State<ApprovingOfficerHome> {
  String? username;
  dynamic authUser;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  void firebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final logger = Logger();
    String? token = await messaging.getToken();
    logger.e("Firebase Token $token");
  }

  void loadCurrentUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final user = auth['user']['name'];

    setState(() {
      username = "$user";
      authUser = auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return authUser != null
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                leading: const SizedBox(),
                title: username != null
                    ? Text(
                        'Hi $username,',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
                      )
                    : Text(
                        'Hi,',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                backgroundColor: Colors.white,
                bottom: TabBar(isScrollable: true, indicatorColor: Theme.of(context).primaryColor, tabs: [
                  Tab(
                    child: Text(
                      'Pending Trips',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  // Container(
                  //   child: Tab(
                  //     child: Text(
                  //       'Pending Ad-Hoc Destination',
                  //       style: Theme.of(context)
                  //           .textTheme
                  //           .bodyText2
                  //           .copyWith(
                  //               color: Theme.of(context).primaryColor),
                  //     ),
                  //   ),
                  // ),
                  Tab(
                    child: Text(
                      'Approved Trips',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ]),
              ),
              body: TabBarView(children: [
                PendingTripsScreen(),
                // PendingDestinationScreen(),
                ApprovedTripsScreen()
              ]),
            ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
