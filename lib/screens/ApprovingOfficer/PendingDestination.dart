import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/ApprovingOfficer/PendingDestinationCard.dart';
import 'package:transport_flutter/components/Empty.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/DestinationApproval.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request;

class PendingDestinationScreen extends StatefulWidget {
  const PendingDestinationScreen({Key? key}) : super(key: key);

  @override
  State<PendingDestinationScreen> createState() => _PendingDestinationScreenState();
}

class _PendingDestinationScreenState extends State<PendingDestinationScreen> {
  String? userID;
  bool _isLoading = false;
  final requestClient = request.Request();
  final _myTrips = BehaviorSubject<List<AdHocDestinationModel>>();

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
        userID = "${user.toString()}";
      });
    }
  }

  void _fetchListMyTrip() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await requestClient.get(Uri.parse('trips/adHoc-destination/approving-officer'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final list = (json.decode(res.body) as List).map((e) {
          print(e);
          return AdHocDestinationModel.fromJson(e);
        }).toList();
        _myTrips.add(list);
      } else if (res.statusCode == 401) {
        await storage.deleteAll();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? '', isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildList(List<AdHocDestinationModel> trips) {
    final listItems = <Widget>[];

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
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationApprovalScreen(
                        tripID: item.tripId,
                        adHocDestinationID: item.id,
                      ),
                    ));
                _fetchListMyTrip();
              },
              child: PendingDestinationCard(tripData: item),
            ),
          )));
    }

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    if (userID == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: <Widget>[
        StreamBuilder<List<AdHocDestinationModel>>(
            stream: _myTrips,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: EmptyPlaceholder(
                      description: "Ad-Hoc Destination not found.",
                      imagePath: "assets/images/no_data.png"),
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
    );
  }
}
