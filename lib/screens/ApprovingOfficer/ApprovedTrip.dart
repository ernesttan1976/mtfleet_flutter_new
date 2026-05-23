import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/ApprovingOfficer/PendingTripCard.dart';
import 'package:transport_flutter/components/Empty.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request_client;

class ApprovedTripsScreen extends StatefulWidget {
  const ApprovedTripsScreen({Key? key}) : super(key: key);

  @override
  ApprovedTripsScreenState createState() => ApprovedTripsScreenState();
}

class ApprovedTripsScreenState extends State<ApprovedTripsScreen> {
  String? userID;
  bool _isLoading = false;
  final request = request_client.Request();
  final _myTrips = BehaviorSubject<List<TripDriverModel>>();
  var logger = Logger();

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
      final res = await request.get(Uri.parse('trips/approving-officer?approvalStatus=Approved'));
      logger.e(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final tripList = (json.decode(res.body) as List).map((e) {
          logger.e(res.body);
          return TripDriverModel.fromJson(e);
        }).toList();
        tripList.sort((a, b) => b.id.compareTo(a.id));
        _myTrips.add(tripList);
      } else if (res.statusCode == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error', isPop: false);
      }
    } catch (e) {
      /* if (e.response.data['statusCode'] == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      }*/
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildList(List<TripDriverModel> trips) {
    List<Widget> listItems = [];

    for (var item in trips) {
      listItems.add(Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {},
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
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return ListView(
                        children: _buildList(snapshot.data!),
                      );
                    }
                    return const Center(
                      child: EmptyPlaceholder(
                          description: "Approved Trip not found.", imagePath: "assets/images/no_data.png"),
                    );
                  }),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
