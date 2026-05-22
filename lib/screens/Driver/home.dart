import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/Driver/PerformanceCard.dart';
import 'package:transport_flutter/screens/Driver/bocTripView.dart';
import 'package:transport_flutter/screens/Driver/tripForm.dart';
import 'package:transport_flutter/screens/Driver/tripPageView.dart';
import 'package:transport_flutter/util/currentUserData.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({Key? key}) : super(key: key);

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  final dioClient = AuthedDio.instance.dio;
  String? name;
  String? uid;
  final _vehicleServicings = BehaviorSubject<List<VehicleServicingModel>>();
  dynamic userJoined;
  dynamic currentRole;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  void loadCurrentUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final user = auth['user']['name'];
    var roleString = await getCurrentRole();
    setState(() {
      name = user;
      uid = "${auth['user']['id']}";
      userJoined = auth['user']['createdAt'];
      currentRole = roleString;
    });
    loadVSs();
  }

  loadVSs() async {
    try {
      final dio = await dioClient;
      final response = await dio.get("/vehicle-servicing/driver");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final vehicleServicingList = (response.data as List)
            .map((e) => VehicleServicingModel.fromJson(e))
            .toList();
        _vehicleServicings.add(vehicleServicingList);
      } else if (response.statusCode == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showAlertDialog(context, 'Error', response.statusMessage ?? '', isPop: false);
      }
    } catch (e) {
      // showAlertDialog(context, 'Error', e.response.data['message'], isPop: false);
    }
  }

  void _mTRCFormAlert() {
    showDialog(
      context: context,
      // barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You clicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            child: const Text(
              "Does this trip require MT RAC form approval?",
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: _vechicleCommaderAlert,
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripFormScreen(false, false),
                                // mtrcApprovalRequired,isVehicleCommander
                              ));
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        );
      },
    );
  }

  void _vechicleCommaderAlert() {
    showDialog(
      context: context,
      // barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You clicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            child: const Text(
              "Is there Vehicle Commander/Front Passenger Present for the trip?",
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TripPageView(true, true)
                                  // mtrcApprovalRequired,isVehicleCommander
                                  ))
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripPageView(true, false),
                                // mtrcApprovalRequired,isVehicleCommander
                              ))
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              child: uid != null
                  ? Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Flexible(
                                    child: name != null
                                        ? Text(
                                            'Hi, $name,',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(color: Theme.of(context).primaryColor),
                                          )
                                        : Text(
                                            'Hi,',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(color: Theme.of(context).primaryColor),
                                          )),
                              ),
                            ],
                          ),
                          // Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          // Row(
                          //   children: <Widget>[
                          //     Container(
                          //       child: Flexible(child: Text('Upcoming Preventive Maintenance', style: Theme.of(context).textTheme.headline6)),
                          //     ),
                          //   ],
                          // ),
                          // Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          // StreamBuilder<List<VehicleServicingModel>>(
                          //     stream: _vehicleServicings,
                          //     builder: (context, snapshot) {
                          //       if (snapshot.data == null) return CircularProgressIndicator();
                          //       return MaintenanceCard(vehicleServicings: snapshot.data);
                          //     }),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          PerformanceCardSection(uid: uid, userJoined: userJoined),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  height: 60,
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      )),
                                      side:
                                          WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                                    ),
                                    onPressed: () async {
                                      var roleString = await getCurrentRole();
                                      if (roleString == 'PRE_APPROVED_DRIVER') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TripFormScreen(false, false),
                                              // mtrcApprovalRequired,isVehicleCommander
                                            ));
                                      } else {
                                        _mTRCFormAlert();
                                      }
                                    },
                                    child: const Text(
                                      "Initiate New Trip",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  height: 60,
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      )),
                                      side:
                                          WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                                    ),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BOCTripPageView(),
                                          )),
                                    },
                                    child: const Text(
                                      "BOS/AOS/POL/DI/AHS",
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        ],
                      ))
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ],
      ),
      onRefresh: () => loadVSs(),
    );
  }
}
