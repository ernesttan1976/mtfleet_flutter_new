import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/Driver/DestinationListCard.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/request.dart' as request_util;

import 'elogBookForm.dart';

class ElogBookScreen extends StatefulWidget {
  final int? tripdataId;
  final num? currentMeterReading;

  const ElogBookScreen({
    Key? key,
    this.tripdataId,
    this.currentMeterReading,
  }) : super(key: key);

  @override
  State<ElogBookScreen> createState() => _ElogBookScreenState();
}

class _ElogBookScreenState extends State<ElogBookScreen> {
  int? tripID;

  bool isCancelling = false;
  final dioClient = AuthedDio.instance.dio;

  final request = request_util.Request();
  final _eLogBookScaffoldKey = GlobalKey<ScaffoldState>();

  final _tripModel = BehaviorSubject<TripDetailModel>();
  TripDetailModel? _tripDetailModel;
  bool _isLoading = false;

  final GlobalKey<FormBuilderState> _initialMeterReadingFormKey = GlobalKey<FormBuilderState>();

  bool tripEnded = false;

  Destination? desSelected;

  bool? adHoc;

  @override
  void initState() {
    super.initState();
    tripID = widget.tripdataId;
    _fetchTripDetail();
  }

  @override
  void dispose() {
    _tripModel.close();
    super.dispose();
  }

  void _fetchTripDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await request.get(Uri.parse('trips/$tripID'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final bodyJson = json.decode(res.body);
        final fetchedModel = TripDetailModel.fromJson(bodyJson);
        _tripDetailModel = fetchedModel;
        _tripModel.add(fetchedModel);
        if ((fetchedModel.destinations).isNotEmpty) {
          setState(() {
            desSelected = fetchedModel.destinations.first;
          });
        }
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase?.toString() ?? 'Unknown error');
      }
    } on DioException catch (e) {
      showAlertDialog(context, 'Error', e.response?.data?['message']?.toString() ?? e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  void startDestination(int desId, int? currentMeterReading, TimeOfDay time) async {
    setState(() {
      _isLoading = true;
    });
    final startTime = DateTime.now().copyWith(hourN: time.hour, p: time.minute).toUtc().toIso8601String();
    final dio = await dioClient;
    try {
      final res = await dio.post('/trips/start-destination',
          data: {"destinationId": desId, "currentMeterReading": currentMeterReading, 'startTime': startTime});
      if (res.statusCode == 200 || res.statusCode == 201) {
        _fetchTripDetail();
        showAlertDialog(context, 'Success', res.statusMessage?.toString() ?? 'Success', isPop: false);
      } else {
        showAlertDialog(context, 'Error', res.statusMessage?.toString() ?? 'Unknown error', isPop: false);
      }
    } on DioException catch (e) {
      showAlertDialog(context, 'Error', e.response?.data?.toString() ?? e.toString(), isPop: false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  // void newDestinationFormAlert(dynamic inProgressDestination,
  //     dynamic newDestination, var requisitionerPurpose) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         // title: new Text('You clicked on'),
  //         elevation: 10,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         content: Container(
  //           child: Text(
  //             "To start a new destination, you have to end your current destination. Are you ready to end current destination?",
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //         actions: [
  //           Container(
  //               color: Colors.transparent,
  //               padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
  //               width: MediaQuery.of(context).size.width * 1.0,
  //               height: 50,
  //               child: Row(
  //                 children: <Widget>[
  //                   Container(
  //                     width: MediaQuery.of(context).size.width * 0.35,
  //                     padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  //                     child: FlatButton(
  //                       color: Theme.of(context).primaryColor,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30.0),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                         Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => ELogBookFormScreen(
  //                           destinationId: destId,
  //                               ),
  //                             ));
  //                       },
  //                       child: Text(
  //                         "Yes",
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                   ),
  //                   Spacer(),
  //                   Container(
  //                     width: MediaQuery.of(context).size.width * 0.35,
  //                     padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
  //                     child: OutlineButton(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30.0),
  //                       ),
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       borderSide:
  //                           BorderSide(color: Theme.of(context).primaryColor),
  //                       child: Text(
  //                         "No",
  //                         style: TextStyle(color: Colors.black),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ))
  //         ],
  //       );
  //     },
  //   );
  // }

  int checkDestinationProgress() {
    int count = 0;

    for (var des in _tripDetailModel!.destinations) {
      if (des.status == "InProgress") {
        count = count + 1;
        break;
      }
    }
    // for (var des in trip['ad_hoc_destinations']) {
    //   if (des['approvalStatus'] == "Approved") {
    //     if (des['status'] == "InProgress") {
    //       count = count + 1;
    //       break;
    //     }
    //   }
    // }
    return count;
  }

  dynamic getInProgressDestination() {
    dynamic id;
    bool adhoc = false;
    String startTime = "";

    for (var des in _tripDetailModel!.destinations) {
      if (des.status == "InProgress") {
        id = des.id;
        adhoc = false;
        // if (des['e_log'] != null) {
        //   startTime = des['e_log']['startTime'];
        // }
        break;
      }
    }

    // for (var des in trip['ad_hoc_destinations']) {
    //   if (des['approvalStatus'] == "Approved") {
    //     if (des['status'] == "InProgress") {
    //       id = des['id'];
    //       adhoc = true;
    //       if (des['e_logs'].length > 0) {
    //         startTime = des['e_logs'][0]['startTime'];
    //       }
    //       break;
    //     }
    //   }
    // }
    return {'id': id, 'isAdhoc': adhoc, "startTime": startTime};
  }

  void vehicleInProgressCheck() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text(
            "Vehicle is Already in Trip...",
            textAlign: TextAlign.center,
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
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                          "OK",
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

  void endDestination(Destination des, bool isEnd, TimeOfDay time) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ELogBookFormScreen(
            destinationId: des.id,
            detailTrip: _tripDetailModel,
            destination: des,
            isEnd: isEnd,
            endTime: time,
          ),
        ));

    _fetchTripDetail();
  }

  void startNewDestination(dynamic desId, bool adHoc) async {
    print("New Destination Id: $desId");
    print("New Ad-hoc Destination: $adHoc");

    if (adHoc) {
      if (checkDestinationProgress() != 0) {
        print("Ad-Hoc is already in progress is Already in-Progress");
      } else {
        var updateTrip = _tripDetailModel;
        var requisitionerPurpose = "";
        // for (var i = 0; i < updateTrip['ad_hoc_destinations'].length; i++) {
        //   var des = updateTrip['ad_hoc_destinations'][i];
        //
        //   if (des['id'] == desId) {
        //     des['status'] = "InProgress";
        //     requisitionerPurpose = des['requisitionerPurpose'];
        //   }
        // }

        // Send Trip data to backend Start
        DateFormat dateFormat = DateFormat.Hm();
        String getTime = dateFormat.format(DateTime.now());
        var data = {
          "newDestination": {"id": desId, "isAdhoc": adHoc},
          "eLogData": {
            "startTime": "$getTime:00.000",
            "vehicleNumber": _tripDetailModel!.vehicle?.vehicleNumber,
            "requisitionerPurpose": requisitionerPurpose
          },
          "tripID": tripID
        };

        int completedDestination = checkCompletedDestination();
        if (completedDestination == 0) {
          // 1. Fetch All Trip which are started and same vehicle number
          var dio = await dioClient;
          var result = await dio
              .get("/trips?vehicle.vehicleNumber=${_tripDetailModel!.vehicle?.vehicleNumber}&isTripStarted=true");
          if (result.data.length > 0) {
            vehicleInProgressCheck();
          } else {
            // 2. Fetch Meter Reading of Vehicle From Last Trip
            var dio = await dioClient;
            var meterReadingQueryResult =
                await dio.get("/trips/getLastMeterReading?vehicleNumber=${_tripDetailModel!.vehicle?.vehicleNumber}");
            getInitialMeterReading(
              data,
              updateTrip,
              "${meterReadingQueryResult.data['meterReading']}",
            );
          }
          // Send Trip data to backend End
        } else {
          data['initalMeterReading'] = null;
          var dataJSON = jsonEncode(data);
          var dio = await dioClient;
          var response = await dio.post("/destination/start", data: dataJSON);

          if (response.statusCode == 200) {
            _fetchTripDetail();
          }
        }
      }
    } else {
      if (checkDestinationProgress() != 0) {
        print("Trip is Already in-Progress Please fill the Elog Form to start new Destination");
      } else {
        var updateTrip = _tripDetailModel;
        var requisitionerPurpose = "";

        for (var i = 0; i < updateTrip!.destinations.length; i++) {
          var des = updateTrip.destinations[i];

          if (des.id == desId) {
            des.status = "InProgress";
            requisitionerPurpose = des.requisitionerPurpose;
          }
        }

        DateFormat dateFormat = DateFormat.Hm();
        String getTime = dateFormat.format(DateTime.now());
        var data = {
          "newDestination": {"id": desId, "isAdhoc": adHoc},
          "eLogData": {
            "startTime": "$getTime:00.000",
            "vehicleNumber": _tripDetailModel!.vehicle?.vehicleNumber,
            "requisitionerPurpose": requisitionerPurpose
          },
          "tripID": tripID
        };
        int completedDestination = checkCompletedDestination();
        if (completedDestination == 0) {
          // 1. Fetch All Trip which are started and same vehicle number
          var dio = await dioClient;
          var result = await dio
              .get("/trips?vehicle.vehicleNumber=${_tripDetailModel!.vehicle?.vehicleNumber}&isTripStarted=true");
          print(result.data);
          if (result.data.length > 0) {
            vehicleInProgressCheck();
          } else {
            // 2. Fetch Meter Reading of Vehicle From Last Trip
            var dio = await dioClient;
            var meterReadingQueryResult =
                await dio.get("/trips/getLastMeterReading?vehicleNumber=${_tripDetailModel!.vehicle?.vehicleNumber}");
            getInitialMeterReading(
              data,
              updateTrip,
              "${meterReadingQueryResult.data['meterReading']}",
            );
          }
        } else {
          data['initalMeterReading'] = null;
          var dataJSON = jsonEncode(data);
          var dio = await dioClient;
          var response = await dio.post("/destination/start", data: dataJSON);

          if (response.statusCode == 200) {
            _fetchTripDetail();
          }
        }
      }
    }
  }

  int checkCompletedDestination() {
    int count = 0;
    for (var des in _tripDetailModel!.destinations) {
      if (des.status == "Completed") {
        count = count + 1;
        break;
      }
    }
    // for (var des in trip['ad_hoc_destinations']) {
    //   if (des['approvalStatus'] == "Approved") {
    //     if (des['status'] == "Completed") {
    //       count = count + 1;
    //       break;
    //     }
    //   }
    // }
    return count;
  }

  void confirmCancelTrip() async {
    setState(() {
      _isLoading = true;
    });
    Navigator.of(context).pop();
    // var inProgressDest = getInProgressDestination();
    // bool isDestInProgress = inProgressDest["id"] != null;
    // print("In Progres DEST");
    // if (isDestInProgress) {
    //   _eLogBookScaffoldKey.currentState.showSnackBar(SnackBar(
    //     content: Text(
    //       "Please complete the current in-progress destination in order to cancel the trip.",
    //       textAlign: TextAlign.center,
    //     ),
    //   ));
    // } else {
    try {
      var response = await request.patch(Uri.parse('trips/cancel/$tripID'));
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {
        _fetchTripDetail();
        showAlertDialog(context, 'Success', response.reasonPhrase?.toString() ?? 'Success', isPop: false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
  }

  void onCancelTrip() async {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Confirm"),
      onPressed: () => confirmCancelTrip(),
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Cancel Trip"),
      content: Text("Are you sure you want to cancel the trip?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Get Initial Meter Reading
  void getInitialMeterReading(var data, var updateTrip, String defaultMeterReading) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            Navigator.of(context).pop();
            _fetchTripDetail();
          },
          child: AlertDialog(
            title: Text('Current Meter Reading Form'),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: SizedBox(
                height: 200,
                child: FormBuilder(
                  key: _initialMeterReadingFormKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FormBuilderTextField(
                          name: "meterReading",
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                            FormBuilderValidators.min(0)
                          ]),
                          initialValue: defaultMeterReading,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                              labelText: "Current Meter Reading",
                              hintText: "Meter Reading (km)",
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )),
                              side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                            ),
                            onPressed: () async {
                              if (_initialMeterReadingFormKey.currentState!.validate()) {
                                _initialMeterReadingFormKey.currentState!.save();

                                data['initalMeterReading'] =
                                    int.tryParse(_initialMeterReadingFormKey.currentState!.value['meterReading']);

                                var dataJSON = jsonEncode(data);
                                var dio = await dioClient;
                                var response = await dio.post("/destination/start", data: dataJSON);

                                if (response.statusCode == 200) {
                                  _fetchTripDetail();

                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  bool checkLastDestination(var destinationData) {
    int totalAccpetedDestination = 0;
    int totalCompletedDestination = 0;

    for (var des in destinationData['destinations']) {
      totalAccpetedDestination = totalAccpetedDestination + 1;
      if (des['status'] == "Completed") {
        totalCompletedDestination = totalCompletedDestination + 1;
      }
    }

    for (var des in destinationData['ad_hoc_destinations']) {
      if (des['approvalStatus'] == "Approved") {
        totalAccpetedDestination = totalAccpetedDestination + 1;

        if (des['status'] == "Completed") {
          totalCompletedDestination = totalCompletedDestination + 1;
        }
      }
    }

    return (totalAccpetedDestination - 1) == totalCompletedDestination;
  }

  bool allDestinationCompleted(var destinationData) {
    int totalAccpetedDestination = 0;
    int totalCompletedDestination = 0;

    for (var des in destinationData['destinations']) {
      totalAccpetedDestination = totalAccpetedDestination + 1;
      if (des['status'] == "Completed") {
        totalCompletedDestination = totalCompletedDestination + 1;
      }
    }

    for (var des in destinationData['ad_hoc_destinations']) {
      if (des['approvalStatus'] == "Approved" || des['approvalStatus'] == "Pending") {
        totalAccpetedDestination = totalAccpetedDestination + 1;
        if (des['status'] == "Completed") {
          totalCompletedDestination = totalCompletedDestination + 1;
        }
      }
    }

    return totalAccpetedDestination == totalCompletedDestination;
  }

  bool checkAllCompletedDestination(List<Destination> destinationData) {
    int totalAccpetedDestination = 0;
    int totalCompletedDestination = 0;

    for (var des in destinationData) {
      totalAccpetedDestination = totalAccpetedDestination + 1;
      if (des.status == "Completed") {
        totalCompletedDestination = totalCompletedDestination + 1;
      }
    }

    // for (var des in destinationData['ad_hoc_destinations']) {
    //   if (des['approvalStatus'] == "Approved") {
    //     totalAccpetedDestination = totalAccpetedDestination + 1;
    //
    //     if (des['status'] == "Completed") {
    //       totalCompletedDestination = totalCompletedDestination + 1;
    //     }
    //   }
    // }

    return totalAccpetedDestination == totalCompletedDestination;
  }

  void onEndTrip() async {
    print("Trip End My Darling");
    setState(() {
      _isLoading = true;
    });
    try {
      var dio = await dioClient;
      var response = await dio.patch("/trips/end/$tripID");
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        _fetchTripDetail();
        showAlertDialog(context, 'Success', response.statusMessage?.toString() ?? 'Success', isPop: false);
        setState(() {
          tripEnded = true;
        });
      } else {
        showAlertDialog(context, 'Error', response.statusMessage?.toString() ?? 'Unknown error', isPop: false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
  }

  List<Widget> _buildChildren(TripDetailModel myTripData) {
    var myList = [
      Row(
        children: <Widget>[
          Text('Trip Date', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
      Row(
        children: <Widget>[
          Text(myTripData.tripDate!.formatDateddMMMyyyyHHmmaa, style: Theme.of(context).textTheme.bodyText1),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Text('Vehicle Number',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
      Row(
        children: <Widget>[
          Text(myTripData.vehicle?.vehicleNumber ?? '', style: Theme.of(context).textTheme.bodyText1),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('Safety Measure',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
              child: Text(
                  myTripData.mtracForm == null
                      ? "There is no safety measure for this trip."
                      : myTripData.mtracForm?.safetyMeasures == null
                          ? "There is no safety measure for this trip"
                          : myTripData.mtracForm!.safetyMeasures!,
                  style: Theme.of(context).textTheme.bodyText1)),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('Destination List',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
      ...myTripData.sortDestination().asMap().keys.map((index) {
        bool showStart = false;
        final item = myTripData.destinations[index];
        if (index == 0) {
          showStart = true;
        } else {
          final preItem = myTripData.destinations[index - 1];
          if (preItem.status != "InProgress" && preItem.status != "Inactive") {
            showStart = true;
          } else {
            showStart = false;
          }
        }
        return DestinationListCard(
          destinationData: item,
          showStart: showStart,
          startDestination: () {
            debugPrint("startDestination called");
            dialogTime((val) async {
              final currentMeterReading =
                  widget.currentMeterReading == 0 ? _tripDetailModel!.currentMeterReading : widget.currentMeterReading;
              debugPrint(" $currentMeterReading");
              startDestination(item.id, currentMeterReading?.toInt(), val);
            });
          },
            endDestination: (int desId, bool adHoc) async {
            dialogTime((val) {
              endDestination(item, index == myTripData.destinations.length - 1, val);
            });
          },
        );
      }),
      const SizedBox(
        height: 40,
      ),
      if (myTripData.tripStatus != 'Cancelled' && myTripData.tripStatus != 'Completed')
        Column(
          children: <Widget>[
            // Container(
            //     width: MediaQuery.of(context).size.width * 0.9,
            //     padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            //     child: FlatButton(
            //       color: Theme.of(context).primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30.0),
            //       ),
            //       onPressed: () {
            //         onEndTrip();
            //       },
            //       child: Text(
            //         "End Trip",
            //         style: TextStyle(color: Colors.white),
            //       ),
            //     )),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Color(0xffff0033)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                onPressed: onCancelTrip,
                child: Text(
                  "Cancel Trip",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width * 0.9,
            //   padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            //   child: OutlineButton(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30.0),
            //     ),
            //     onPressed: () async {
            //       await Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => AdHocDestinationFormScreen(
            //               tripId: myTripData.id,
            //               tripDate: myTripData.tripDate,
            //             ),
            //           ));
            //       _fetchTripDetail();
            //     },
            //     borderSide: BorderSide(color: Theme.of(context).primaryColor),
            //     child: Text(
            //       "Add Trip Deviation",
            //       style: TextStyle(color: Theme.of(context).primaryColor),
            //     ),
            //   ),
            // )
          ],
        )
      else
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          height: 55,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.green.shade400),
          child: Text('Trip is completed Successfully'),
        ),
      const SizedBox(
        height: 40,
      ),
    ];

    return myList;
  }

  void dialogTime(Function(TimeOfDay) callBack) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              'SELECT TIME',
              style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (child != null) child,
            ],
          ),
        );
      },
    );
    if (timeOfDay != null) {
      callBack.call(timeOfDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _eLogBookScaffoldKey,
      appBar: AppBar(
        title: Text(
          "ElogBook",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: <Widget>[
        StreamBuilder<TripDetailModel>(
            stream: _tripModel,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const SizedBox();
              }
              snapshot.data?.destinations.sort(
                (a, b) => a.createdAt!.microsecondsSinceEpoch.compareTo(
                  b.createdAt!.microsecondsSinceEpoch,
                ),
              );
              return ListView(
                children: _buildChildren(snapshot.data!),
              ).paddingHorizontal(18);
            }),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
      ],
    );
  }
}
