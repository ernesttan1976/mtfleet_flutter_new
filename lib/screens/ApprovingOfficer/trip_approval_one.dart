import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/request.dart' as request_util;

import 'MTRACApprovalTwo.dart';
import 'TripApproval.dart';

class TripApprovalScreen extends StatefulWidget {
  final String? tripID;

  const TripApprovalScreen({Key? key, this.tripID}) : super(key: key);

  @override
  TripApprovalScreenState createState() => TripApprovalScreenState();
}

class TripApprovalScreenState extends State<TripApprovalScreen> {
  final dioClient = AuthedDio.instance.dio;
  bool _isLoading = false;
  // TODO: Wire up _formKey when form is added or remove if unnecessary.
  // final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String? myTripId;
  final request = request_util.Request();
  final BehaviorSubject<TripDetailModel> _tripModel = BehaviorSubject<TripDetailModel>();

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
        final decodedBody = json.decode(res.body);
        Logger logger = Logger();
        logger.e(decodedBody);
        final TripDetailModel tripModel = TripDetailModel.fromJson(decodedBody);
        _tripModel.add(tripModel);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error');
      }
    } catch (e) {
      showAlertDialog(context, 'Catch Error', e.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<Widget> _buildChildren(TripDetailModel tripData) {
    var myList = [
      Row(
        children: <Widget>[
          Text('Date:', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              tripData.tripDate!.formatDateTime('dd MMM yyyy'),
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'Vehicle License Number:',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "${tripData.vehicle != null ? tripData.vehicle?.vehicleNumber : 'N/A'}",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'Type:',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "${tripData.vehicle?.model}",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      for (var item in tripData.destinations)
        Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'To:',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    item.to,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    "Requisitioner's Purpose",
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    item.requisitionerPurpose,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ],
        ),
      15.verticalSpace,
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: OutlinedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            if (tripData.mtracForm != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MTRACApprovalSecondScreen(
                    tripModel: tripData,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripApprovalFinalScreen(
                    tripID: tripData.id,
                  ),
                ),
              );
            }
          },
          child: const Text(
            "Next",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
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
            style: Theme.of(context).textTheme.headline5?.text244F4E.semiBold,
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
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
