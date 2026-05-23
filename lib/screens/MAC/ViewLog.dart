import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/extensions/date_time_extension.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/MAC/VehicleUpdate.dart';
import 'package:transport_flutter/util/request.dart' as request_api;

class ViewLogScreen extends StatefulWidget {
  final int servicingId;

  const ViewLogScreen({Key? key, required this.servicingId}) : super(key: key);

  @override
  State<ViewLogScreen> createState() => _ViewLogScreenState();
}

class _ViewLogScreenState extends State<ViewLogScreen> {
  final request = request_api.Request();
  final _elogs = BehaviorSubject<List<UpdateCheckInModel>>();

  @override
  void initState() {
    super.initState();
    _fetchUpdateElogs();
  }

  void _fetchUpdateElogs() async {
    try {
      final res = await request.get(Uri.parse('check-in/updates/${widget.servicingId}'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final list = (json.decode(res.body) as List).map((e) => UpdateCheckInModel.fromJson(e)).toList();
        final finalList = List<UpdateCheckInModel>.from(list.reversed);
        _elogs.add(finalList);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error');
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Update Logs',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // elevation: 5,
      ),
      body: StreamBuilder<List<UpdateCheckInModel>>(
          stream: _elogs,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'Update Logs: ',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    for (var update in snapshot.data!)
                      Container(
                        key: Key("${update.id}"),
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                update.updatedAt != null ? update.updatedAt!.formatDateddMMyyyy : '--',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: Column(
                                children: <Widget>[
                                  Text(update.notes,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)),
                                  Text(
                                    "Expected Check-out Date: ${update.dateOfCompletion != null ? update.dateOfCompletion!.formatDateddMMyyyy : '--'}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12.0, color: Colors.black),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VehicleUpdateScreen(servicingID: widget.servicingId, currentUpdates: snapshot.data),
                              ));
                          _fetchUpdateElogs();
                        },
                        child: Text(
                          "Add Update",
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
