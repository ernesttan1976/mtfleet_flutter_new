import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/ApprovedTripDoc.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/MTRACApprovedDoc.dart';
import 'package:transport_flutter/util/request.dart' as Request;

class DestinationApprovalScreen extends StatefulWidget {
  final int? tripID;
  final int? adHocDestinationID;

  DestinationApprovalScreen({Key? key, this.tripID, this.adHocDestinationID}) : super(key: key);

  @override
  _DestinationApprovalScreenState createState() => _DestinationApprovalScreenState();
}

class _DestinationApprovalScreenState extends State<DestinationApprovalScreen> {
  late int myTripId;
  var request = new Request.Request();

  bool _isLoading = false;

  final _tripModel = BehaviorSubject<TripDetailModel>();
  final dioClient = AuthedDio.instance.dio;

  @override
  void initState() {
    super.initState();
    myTripId = widget.tripID!;
    _fetchTripDetail();
  }

  void _fetchTripDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await request.get(Uri.parse('trips/$myTripId'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final _a = json.decode(res.body);
        final _model = TripDetailModel.fromJson(_a[0]);
        _tripModel.add(_model);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildChildren(TripDetailModel trip) {
    var myList = <Widget>[];
    if (trip.mtracForm != null) {
      Color? myColor;
      if (trip.mtracForm?.overAllRisk == "MEDIUM") {
        myColor = Colors.orange[500];
      } else if (trip.mtracForm?.overAllRisk == "LOW") {
        myColor = Colors.green;
      } else {
        myColor = Colors.red[500];
      }

      myList.addAll([
        Row(
          children: <Widget>[
            Container(
              child: Flexible(
                  child: Text('Overall Risk:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Flexible(
                    child: Text(
              "${trip.mtracForm?.overAllRisk}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: myColor,
                  ),
            ))),
          ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      ]);
    }

    myList.addAll([
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child:
                    Text('Date:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(trip.tripDate!.formatDateddMMMMHHmma,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      // Row(
      //   children: <Widget>[
      //     Container(
      //       child: Flexible(
      //           child: Text('Additional Destination:',
      //               style: Theme.of(context)
      //                   .textTheme
      //                   .bodyText1
      //                   .copyWith(fontWeight: FontWeight.bold))),
      //     ),
      //   ],
      // ),
      // Row(
      //   children: <Widget>[
      //     Container(
      //       child: Flexible(
      //           child: Text("${widget.adHocDestination}",
      //               style: Theme.of(context)
      //                   .textTheme
      //                   .bodyText1
      //                   .copyWith(fontWeight: FontWeight.normal))),
      //     ),
      //   ],
      // ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child:
                    Text('To:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    ]);

    for (var destination in trip.destinations) {
      myList.add(
          Text(destination.to, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal)));
    }

    // for (var ad_destination in trip['ad_hoc_destinations']) {
    //   if (ad_destination['approvalStatus'] == "Approved") {
    //     myList.add(Row(
    //       children: <Widget>[
    //         Container(
    //           child: Flexible(
    //               child: Text(ad_destination['to'],
    //                   style: Theme.of(context)
    //                       .textTheme
    //                       .bodyText1
    //                       .copyWith(fontWeight: FontWeight.normal))),
    //         ),
    //       ],
    //     ));
    //   }
    // }

    myList.addAll([
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Requisitioner's Purpose",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      ...trip.destinations.map((e) => Text(e.requisitionerPurpose,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Approved Documents:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    ]);

    var fourthList;

    if (trip.mtracForm != null) {
      fourthList = [
        Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                onTap: () => {},
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Trip Approval",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal)),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApprovedTripDocScreen(
                                    approvedTripData: trip,
                                  ),
                                ));
                          },
                          child: Text(
                            "VIEW",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "MTRAC",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MTRACTripDocScreen(
                                    approvedMTRACData: trip,
                                  ),
                                ));
                          },
                          child: Text(
                            "VIEW",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            onPressed: () => {onSubmitApprove()},
            child: Text(
              "Approve",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            onPressed: () {
              denyAlert();
            },
            child: Text(
              "Deny",
              style: TextStyle(color: Colors.black),
            ),
          ),
        )
      ];
    } else {
      fourthList = [
        Container(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.9,
              child: InkWell(
                onTap: () => {},
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Trip Approval",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal)),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApprovedTripDocScreen(
                                    approvedTripData: trip,
                                  ),
                                ));
                          },
                          child: Text(
                            "VIEW",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.normal, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            onPressed: () => {onSubmitApprove()},
            child: Text(
              "Approve",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
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
            onPressed: () {
              denyAlert();
            },
            child: Text(
              "Deny",
              style: TextStyle(color: Colors.black),
            ),
          ),
        )
      ];
    }

    return [...myList, ...fourthList];
  }

  void onSubmitApprove() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dio = await dioClient;
      var res = await dio.patch('/trips/approve/adHoc-destination/${widget.adHocDestinationID}');
      setState(() {
        _isLoading = false;
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        showAlertDialog(context, 'Success', res.statusMessage);
      } else {
        showAlertDialog(context, 'Error', res.statusMessage, isPop: false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, 'Error', e, isPop: false);
    }
  }

  void onSubmitDeny() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dio = await dioClient;
      var res = await dio.patch('/trips/reject/adHoc-destination/${widget.adHocDestinationID}');
      setState(() {
        _isLoading = false;
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        showAlertDialog(context, 'Success', res.statusMessage);
      } else {
        showAlertDialog(context, 'Error', res.statusMessage, isPop: false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, 'Error', e as String, isPop: false);
    }
  }

  void denyAlert() {
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
            child: Text(
              "Are you sure to reject this Ad-Hoc Destination?",
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSubmitDeny();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ad-Hoc Destination Approval",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // elevation: 5,
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<TripDetailModel>(
              stream: _tripModel,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const SizedBox();
                }
                return ListView(
                  children: _buildChildren(snapshot.data!),
                ).paddingHorizontal(20);
              }),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
