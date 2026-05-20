import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/MAC/MaintenanceCard.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/MAC/PreventiveCheckInForm.dart';
import 'package:transport_flutter/util/currentUserData.dart';

class MACHome extends StatefulWidget {
  MACHome({Key? key}) : super(key: key);

  @override
  _MACHomeState createState() => _MACHomeState();
}

class _MACHomeState extends State<MACHome> {
  final dioClient = AuthedDio.instance.dio;

  String? name;
  String? uid;

  final _vehicleServicings = BehaviorSubject<List<VehicleServicingModel>>();

  @override
  void initState() {
    super.initState();
    this.loadUser();
  }

  loadUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final userName = auth['user']['name'];

    setState(() {
      name = "$userName";
      uid = "${auth['user']['id']}";
    });
    this.loadVSs();
  }

  loadVSs() async {
    try {
      final dio = await dioClient;
      final response = await dio.get("/vehicle-servicing/mac");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final _list = (response.data as List).map((e) => VehicleServicingModel.fromJson(e)).toList();
        _vehicleServicings.add(_list);
      } else if (response.statusCode == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (response.statusCode == 401) {
          await storage.deleteAll();
          Navigator.pushReplacementNamed(context, '/login');
        }
        showAlertDialog(context, 'Error', response.statusMessage, isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e as String, isPop: false);
    }
  }

  void _selectionOptionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Please select"),
          content: Container(
            height: 260,
            child: Column(
              children: <Widget>[
                Text("What type of maintenance is this vehicle checking in for?"),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      )),
                      side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PreventiveCheckInFormScreen(
                                maintenanceType: "Preventive",
                              )));

                      this.loadVSs();
                    },
                    child: Text(
                      "Preventive",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )),
                        side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PreventiveCheckInFormScreen(
                                  maintenanceType: "Corrective",
                                )));
                        this.loadVSs();
                      },
                      child: Text(
                        "Corrective",
                        style: TextStyle(color: Colors.black),
                      ),
                    )),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      )),
                      side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PreventiveCheckInFormScreen(
                                maintenanceType: "AVI",
                              )));
                      this.loadVSs();
                    },
                    child: Text(
                      "Annual Vehicle Inspection",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
                      padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Flexible(
                                    child: name != null && name != "null"
                                        ? Text(
                                            'Hi, $name,',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                ?.copyWith(color: Theme.of(context).primaryColor),
                                          )
                                        : Text(
                                            'Hi,',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                ?.copyWith(color: Theme.of(context).primaryColor),
                                          )),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Flexible(
                                    child: Text('Vehicle In Workshop', style: Theme.of(context).textTheme.headline6)),
                              ),
                            ],
                          ),
                          StreamBuilder<List<VehicleServicingModel>>(
                              stream: _vehicleServicings,
                              builder: (context, snapshot) {
                                if (snapshot.data == null) return CircularProgressIndicator();
                                return MaintenanceCard(vehicleServicings: snapshot.data!, refetch: () => loadVSs());
                              }),
                          Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                          Row(
                            children: <Widget>[
                              Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 60,
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    )),
                                    side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                                  ),
                                  onPressed: _selectionOptionAlert,
                                  child: Text(
                                    "Check-in Vehicle",
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ))
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ],
      ),
      onRefresh: () => this.loadVSs(),
    );
  }
}
