import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/ApprovingOfficer/PendingTripCard.dart';
import 'package:transport_flutter/components/Empty.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as Request;

import 'trip_approval_one.dart';

class PendingTripsScreen extends StatefulWidget {
  PendingTripsScreen({Key? key}) : super(key: key);

  @override
  _PendingTripsScreenState createState() => _PendingTripsScreenState();
}

class _PendingTripsScreenState extends State<PendingTripsScreen> {
  String? userID;
  bool _isLoading = false;
  var request = new Request.Request();
  final _myTrips = BehaviorSubject<List<TripDriverModel>>();

  @override
  void initState() {
    super.initState();
    this.loadCurrentUser();
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
    if (this.mounted)
      setState(() {
        userID = "$user";
      });
  }

  void _fetchListMyTrip() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await request.get(Uri.parse('trips/approving-officer?approvalStatus=Pending'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final _list = (json.decode(res.body) as List).map((e) {
          print(e);
          return TripDriverModel.fromJson(e);
        }).toList();
        _list.sort((a, b) => b.id.compareTo(a.id));
        _myTrips.add(_list);
      } else {
        if (res.statusCode == 401) {
          await storage.deleteAll();
          Navigator.pushReplacementNamed(context, '/login');
        }
        showAlertDialog(context, 'Error', res.reasonPhrase, isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e as String, isPop: false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildList(List<TripDriverModel> trips) {
    List<Widget> listItems = [];

    for (var item in trips) {
      listItems.add(Padding(
          padding: new EdgeInsets.all(10.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripApprovalScreen(
                        tripID: item.id.toString(),
                      ),
                    ));
                _fetchListMyTrip();
                // if (item['mt_rac_form'] == null) {
                //   await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => TripApprovalScreen(
                //           tripID: item.id,
                //         ),
                //       ));
                //   refetch();
                // } else {
                //   await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => MTRACApprovalFirstScreen(
                //           tripID: item['id'],
                //         ),
                //       ));
                // }
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
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: EmptyPlaceholder(
                            description: "Pending Trips not found.", imagePath: "assets/images/no_data.png"),
                      );
                    }
                    return ListView(
                      children: _buildList(snapshot.data!),
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
