import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import "package:transport_flutter/constants.dart" as Constants;
import 'package:transport_flutter/screens/MAC/home.dart';
import 'package:transport_flutter/util/currentUserData.dart';

class MACNavigation extends StatefulWidget {
  const MACNavigation({Key? key}) : super(key: key);

  @override
  _MACNavigationState createState() => _MACNavigationState();
}

class _MACNavigationState extends State<MACNavigation> {
  final storage = FlutterSecureStorage();

  List? roles;
  dynamic currentRole;
  String? selectedRoleValue;

  @override
  void initState() {
    super.initState();
    this.loadRoles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showAlertDialogNotification(context, message);
      }
    });
  }

  void loadRoles() async {
    final currentRoleString = await getCurrentRole();
    final cRole = currentRoleString;
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final mainRole = auth['user']['roles'];
    final otherRoles = auth['user']['otherRoles'];

    List allRoles = [mainRole, ...otherRoles];

    List<String> mp = [];
    for (var item in allRoles[0]) {
      print(item);
      if (SUPPORTED_ROLES.contains(item)) mp.add(item);
    }

    setState(() {
      roles = mp;
      selectedRoleValue = cRole.toUpperCase();
    });
  }

  void changeRole(value, context) async {
    setState(() {
      selectedRoleValue = value;
    });
    if (value != null) {
      await storage.write(key: "currentRole", value: value);
      Navigator.of(context).pushReplacementNamed("/appLoading");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
          child: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        height: double.maxFinite,
        child: Stack(
          children: <Widget>[
            ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                    height: 187,
                    padding: EdgeInsets.zero,
                    child: DrawerHeader(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24.0,
                                  semanticLabel: 'Close',
                                ),
                                onPressed: () => Navigator.pop(context)),
                          ),
                          if (roles != null && selectedRoleValue != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                dropdownColor: Theme.of(context).primaryColor,
                                style: TextStyle(color: Colors.white, fontSize: 16),
                                value: selectedRoleValue,
                                items: roles
                                    ?.map((role) => DropdownMenuItem(
                                        child: Text(
                                          role.toString().replaceAll('_', ' '),
                                        ),
                                        value: "$role"))
                                    .toList(),
                                onChanged: (value) {
                                  this.changeRole(value, context);
                                },
                              )),
                            )
                        ],
                      ),
                    )),
                Divider(
                  color: Colors.white,
                  height: 0,
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 60),
                  title: Text(
                    'HOME',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pop(context);
                  },
                ),
                // ListTile(
                //   contentPadding: EdgeInsets.symmetric(horizontal: 60),
                //   title: Text(
                //     'LEARNING VIDEOS',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   onTap: () {
                //     // Update the state of the app.
                //     // ...
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/learning');
                //   },
                // ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 60),
                  title: Text(
                    'LOGOUT',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    // Update the state of the app.
                    // ...
                    await storage.deleteAll();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            new Positioned(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Text("Version ${Constants.CURRENT_VERSION}",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
              ),
            )
          ],
        ),
      )),
      body: MACHome(),
    );
  }
}
