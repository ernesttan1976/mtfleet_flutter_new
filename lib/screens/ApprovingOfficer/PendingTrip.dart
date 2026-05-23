import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/ApprovingOfficer/PendingTripCard.dart';
import 'package:transport_flutter/components/Empty.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request_util;

import 'trip_approval_one.dart';

class PendingTripsScreen extends StatefulWidget {
  const PendingTripsScreen({Key? key}) : super(key: key);

  @override
  PendingTripsScreenState createState() => PendingTripsScreenState();
}

class PendingTripsScreenState extends State<PendingTripsScreen> {
  String? userID;
  bool _isLoading = false;
  final request = request_util.Request();
  final _myTrips = BehaviorSubject<List<TripDriverModel>>();

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
    if (mounted) {
      setState(() {
        userID = "$user";
      });
    }
  }

  void _fetchListMyTrip() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await request.get(Uri.parse('trips/approving-officer?approvalStatus=Pending'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final trips = (json.decode(res.body) as List).map((e) {
          print(e);
          return TripDriverModel.fromJson(e);
        }).toList();
        trips.sort((a, b) => b.id.compareTo(a.id));
        _myTrips.add(trips);
      } else {
        if (res.statusCode == 401) {
          await storage.deleteAll();
          Navigator.pushReplacementNamed(context, '/login');
        }
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error', isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildList(List<TripDriverModel> trips) {
    const padding = EdgeInsets.all(10.0);
    final listItems = <Widget>[];

    for (final item in trips) {
      listItems.add(Padding(
          padding: padding,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripApprovalScreen(
                      tripID: item.id.toString(),
                    ),
                  ),
                );
                _fetchListMyTrip();
              },
              child: PendingTripCard(tripData: item),
            ),
          )));
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return userID != null
        ? Stack(
            children: <Widget>[
              StreamBuilder<List<TripDriverModel>>(
                stream: _myTrips,
                initialData: const [],
                builder: (context, snapshot) {
                  final trips = snapshot.data ?? [];

                  if (trips.isEmpty) {
                    return const Center(
                      child: EmptyPlaceholder(
                        description: "Pending Trips not found.",
                        imagePath: "assets/images/no_data.png",
                      ),
                    );
                  }
                  return ListView(
                    children: _buildList(trips),
                  );
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
