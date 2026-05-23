import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/Driver/TripCard.dart';
import 'package:transport_flutter/components/Empty.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/Driver/elogBook.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request;

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  TripScreenState createState() => TripScreenState();
}

class TripScreenState extends State<TripScreen> {
  String? userID = '';

  final requestClient = request.Request();
  final _myTrips = BehaviorSubject<List<TripDriverModel>>();
  bool _isLoading = false;
  String _lastEnterReading = '0';

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    _fetchListMyTrip();
  }

  @override
  void dispose() {
    _myTrips.close();
    super.dispose();
  }

  void loadCurrentUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final user = auth['user']['id'];
    setState(() {
      userID = "$user";
    });
  }

  void _fetchListMyTrip() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await requestClient.get(Uri.parse('trips/driver'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final list = (json.decode(res.body) as List).map((e) => TripDriverModel.fromJson(e)).toList();
        final finalList = List<TripDriverModel>.from(list.reversed);
        _myTrips.add(finalList);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error occurred');
      }
    } catch (e) {
      showAlertDialog(context, 'Error Catch', e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  void safetyAlert(TripDriverModel tripData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Safety Measure'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text("There is no safety measure for this trip \n\nNote: Click proceed to start the trip"),
          actions: [
            Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
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
                            builder: (context) => ElogBookScreen(
                              tripdataId: tripData.id,
                            ),
                          ));
                    },
                    child: Text(
                      "Proceed",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 20)
          ],
        );
      },
    );
  }

  List<Widget> _buildList(List<TripDriverModel> trips) {
    List<Widget> listItems = [];

    for (var trip in trips) {
      listItems.add(
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: trip.approvalStatus == "Rejected" ? 1 : 5,
            color: trip.approvalStatus == "Rejected" ? Colors.grey[200] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: trip.approvalStatus != "Approved"
                ? TripCard(
                    tripData: trip,
                  )
                : InkWell(
                    onTap: () async {
                      if (trip.tripStatus == 'Completed' || trip.tripStatus == 'InProgress') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElogBookScreen(
                              tripdataId: trip.id,
                              currentMeterReading: 0,
                            ),
                          ),
                        );
                        _fetchListMyTrip();
                      } else {
                        showDialogAddCurrentMeter(trip);
                      }
                    },
                    child: TripCard(
                      tripData: trip,
                    ),
                  ),
          ),
        ),
      );
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Trips",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userID != null
          ? _buildUserIdNotNull()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildUserIdNotNull() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        StreamBuilder<List<TripDriverModel>>(
            stream: _myTrips,
            initialData: [],
            builder: (context, snapshot) {
              final trips = snapshot.data!;
              // Empty
              if (trips.isEmpty) {
                return Center(
                  child: EmptyPlaceholder(description: "No trips found.", imagePath: "assets/images/no_data.png"),
                );
              }

      return ListView(
        children: const [],
      );
            }),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
      ],
    );
  }

  void showDialogAddCurrentMeter(TripDriverModel model) async {
    String currentMeterReading = '0';
    final res = await requestClient.get(Uri.parse('vehicles/last-meter-reading/${model.vehiclesId}'));
    if (res.statusCode == 200 || res.statusCode == 201) {
      currentMeterReading = json.decode(res.body)['meterReading'].toString();
      if ((currentMeterReading).isNotEmpty && currentMeterReading.toLowerCase() != 'null') {
        _lastEnterReading = currentMeterReading;
      }
    } else {
      showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error occurred', isPop: false);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You c_tripDetailModel.currentMeterReadin glicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text('Current Meter Reading'),
          content: TitleAndWidgetShadow(
            title: 'Current Meter Reading',
            child: FormBuilder(
              child: FormBuilderTextField(
                name: 'kvmkdvm',
                initialValue: _lastEnterReading,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "Type here...",
                ),
                onChanged: (val) {
                  currentMeterReading = val!;
                },
              ),
            ),
          ),
          actions: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () async {
                  if (currentMeterReading.isNotEmpty) {
                    if (num.parse(currentMeterReading) < num.parse(_lastEnterReading)) {
                      showAlertDialog(context, "Warring", 'New mileage should greater than trips total mileage',
                          isPop: false);
                    } else {
                      if (num.parse(currentMeterReading) < 0) {
                        showAlertDialog(context, "Warring", 'You can not enter negative number.', isPop: false);
                      } else {
                        Navigator.of(context).pop();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ElogBookScreen(
                                tripdataId: model.id,
                                currentMeterReading: num.parse(currentMeterReading),
                              ),
                            ));
                        _fetchListMyTrip();
                      }
                    }
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
