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
  const MACHome({Key? key}) : super(key: key);

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
    loadUser();
  }

  loadUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final userName = auth['user']['name'];

    setState(() {
      name = "$userName";
      uid = "${auth['user']['id']}";
    });
    loadVSs();
  }

  loadVSs() async {
    try {
      final dio = await dioClient;
      final response = await dio.get("/vehicle-servicing/mac");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = (response.data as List).map((e) => VehicleServicingModel.fromJson(e)).toList();
        _vehicleServicings.add(list);
      } else if (response.statusCode == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (response.statusCode == 401) {
          await storage.deleteAll();
          Navigator.pushReplacementNamed(context, '/login');
        }
        showAlertDialog(context, 'Error', response.statusMessage ?? 'Unknown error', isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
  }

  void _selectionOptionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Please select"),
          content: SizedBox(
            height: 260,
            child: Column(
              children: <Widget>[
                const Text("What type of maintenance is this vehicle checking in for?"),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PreventiveCheckInFormScreen(
                            maintenanceType: "Preventive",
                          ),
                        ),
                      );

                      loadVSs();
                    },
                    child: const Text(
                      "Preventive",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PreventiveCheckInFormScreen(
                            maintenanceType: "Corrective",
                          ),
                        ),
                      );
                      loadVSs();
                    },
                    child: const Text(
                      "Corrective",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PreventiveCheckInFormScreen(
                            maintenanceType: "AVI",
                          ),
                        ),
                      );
                      loadVSs();
                    },
                    child: const Text(
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
            TextButton(
              child: const Text("Close"),
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
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => loadVSs(),
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
                              Flexible(
                                child: name != null && name != "null"
                                    ? Text(
                                        'Hi, $name,',
                                        style: textTheme.headlineMedium?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : Text(
                                        'Hi,',
                                        style: textTheme.headlineMedium?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  'Vehicle In Workshop',
                                  style: textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<List<VehicleServicingModel>>(
                            stream: _vehicleServicings,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) return const CircularProgressIndicator();
                              return MaintenanceCard(
                                vehicleServicings: snapshot.data!,
                                refetch: () => loadVSs(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 60,
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    side: MaterialStateProperty.all(
                                      BorderSide(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  onPressed: _selectionOptionAlert,
                                  child: const Text(
                                    "Check-in Vehicle",
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
