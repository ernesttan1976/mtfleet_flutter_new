import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/request.dart' as Request;

class TripApprovalFinalScreen extends StatefulWidget {
  final int? tripID;

  TripApprovalFinalScreen({Key? key, required this.tripID}) : super(key: key);

  @override
  _TripApprovalFinalScreenState createState() => _TripApprovalFinalScreenState();
}

class _TripApprovalFinalScreenState extends State<TripApprovalFinalScreen> {
  final dioClient = AuthedDio.instance.dio;
  bool _isLoading = false;
  final GlobalKey<FormBuilderState> _safetyKey = GlobalKey<FormBuilderState>();

  late int? myTripId;
  var request = new Request.Request();
  final _tripModel = BehaviorSubject<TripDetailModel>();

  @override
  void initState() {
    super.initState();
    myTripId = widget.tripID;
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
        final _model = TripDetailModel.fromJson(_a);
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

  void onSubmitApprove() async {
    final _safety = _safetyKey.currentState?.value['safety'];
    try {
      setState(() {
        _isLoading = true;
      });
      var dio = await dioClient;
      var res = await dio.post('/trips/approve', data: {
        "tripId": myTripId,
        "safetyMeasures": _safety,
      });
      setState(() {
        _isLoading = false;
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.of(context).popAndPushNamed('/approvingOfficer');
        showAlertDialog(context, 'Success', res.statusMessage, isPop: false);
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

  void onSubmitDeny() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var dio = await dioClient;
      var res = await dio.patch('/trips/reject/$myTripId');
      setState(() {
        _isLoading = false;
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.of(context).popAndPushNamed('/approvingOfficer');
        showAlertDialog(context, 'Success', res.statusMessage, isPop: false);
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
              "Are you sure to reject this trip?",
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
                      child:TextButton(
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

  List<Widget> _buildChildren(TripDetailModel tripData) {
    var myList = [
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
                child: Text(tripData.tripDate!.formatDateTime('dd MMM yyyy'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Vehicle License Number:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("${tripData.vehicle != null ? tripData.vehicle?.vehicleNumber : 'N/A'}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child:
                    Text('Type:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("${tripData.vehicle?.model}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      for (var item in tripData.destinations)
        (Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text('To:',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text("${item.to}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text("Requisitioner's Purpose",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text("${item.requisitionerPurpose}",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
                ),
              ],
            ),
          ],
        )),
      20.verticalSpace,
      TitleAndWidgetShadow(
        title: 'Safety Measures:',
        child: FormBuilder(
          key: _safetyKey,
          child: FormBuilderTextField(
            name: 'safety',
            maxLines: 10,
            minLines: 4,
            validator: FormBuilderValidators.required(),
            decoration: InputDecoration(
              hintText: "Please elaborate on the safety or risk mitigating measures taken.",
            ),
            onChanged: (val) {},
          ),
        ),
      ),
      15.verticalSpace,
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.only(top: 20),
        child:TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          onPressed: () {
            if (_safetyKey.currentState!.saveAndValidate()) {
              onSubmitApprove();
            }
          },
          child: Text(
            "Approve",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.only(top: 10),
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
    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Trip Approval',
            style: Theme.of(context).textTheme.headlineSmall?.text244F4E.semiBold,
          ).paddingOnly(left: 25),
          15.verticalSpace,
          Expanded(
            child: Stack(
              children: <Widget>[
                StreamBuilder<TripDetailModel>(
                    stream: _tripModel,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const SizedBox();
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: _buildChildren(snapshot.data!),
                        ).paddingHorizontal(20),
                      );
                    }),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
