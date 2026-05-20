import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import "package:transport_flutter/constants.dart" as Constants;
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/MAC/CheckOutForm.dart';
import 'package:transport_flutter/screens/MAC/PreventiveCheckInForm.dart';
import 'package:transport_flutter/screens/MAC/ViewLog.dart';
import 'package:transport_flutter/util/request.dart' as Request;

class MaintenanceScreen extends StatefulWidget {
  final VehicleServicingModel? service;

  MaintenanceScreen({Key? key, this.service}) : super(key: key);

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  var request = new Request.Request();
  final dioClient = AuthedDio.instance.dio;
  final _vehicleServicingModel = BehaviorSubject<VehicleServicingDetailModel>();

  @override
  void initState() {
    super.initState();
    _fetchVehicleServicing();
  }

  void _fetchVehicleServicing() async {
    try {
      final res = await request.get(Uri.parse('check-in/${widget.service?.vehicleId}'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final _a = json.decode(res.body);
        final _model = VehicleServicingDetailModel.fromJson(_a);
        _vehicleServicingModel.add(_model);
      } else {
        if (res.statusCode == 400) {
          showAlertDialog(context, 'Notification', 'checked out');
        } else {
          showAlertDialog(context, 'Error', res.reasonPhrase);
        }
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e);
    }
  }

  List<Widget> _buildChildren(VehicleServicingDetailModel model) {
    var myChildren = [
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(
                    widget.service!.maintenanceType == "AVI"
                        ? 'Type of Maintenance : Annual Vehicle Inspection '
                        : 'Type of Maintenance : ${widget.service!.maintenanceType}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Work Center",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.workCenter}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Telephone No",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.telephoneNo}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Vehicle Number:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${widget.service!.vehicle!.vehicleNumber}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child:
                    Text('Model', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${widget.service!.vehicle!.model}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
    ];

    if (widget.service?.maintenanceType == "Preventive") {
      myChildren.addAll([
        Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Container(
              child: Flexible(
                  child: Text('Type of Preventive Maintenance',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              child: Flexible(
                  child: Text('${widget.service!.maintenanceType}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
            ),
          ],
        )
      ]);
    }

    var newList = [
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Fuel Sensor Tag",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.frontSensorTag}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Basic Issue Tools:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      if (model.basicIssueTools.isNotEmpty)
        for (var tool in model.basicIssueTools)
          Row(
            children: <Widget>[
              Container(
                child: Flexible(
                    child: Text('${tool.name}: ${tool.quantity}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
              ),
            ],
          ),
      if (model.basicIssueTools.isEmpty)
        Row(
          children: <Widget>[
            Container(
              child: Flexible(
                  child: Text('None',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
            ),
          ],
        ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Condition of Vehicle:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: model.images.isNotEmpty ? 200 : 30,
        child: model.images.isNotEmpty
            ? ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (var pic in model.images)
                    Container(
                      // child: Image.network(
                      //     "${Constants.SERVER_URI}${pic['url']}"),
                      child: CachedNetworkImage(
                        imageUrl: "${Constants.SERVER_URI_API}${pic.path}",
                        // placeholder: (context, url) =>
                        //     CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                ],
              )
            : Row(
                children: <Widget>[
                  Container(
                    child: Flexible(
                        child: Text('No Images Found!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
                  ),
                ],
              ),
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(widget.service!.maintenanceType == "Corrective" ? "Corrective Maintenance:" : "Defect:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(
                    widget.service!.maintenanceType == "Corrective"
                        ? model.correctiveMaintenance?.correctiveMaintenance ?? '--'
                        : "s",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Date In:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(model.dateIn == null ? '--' : '${model.dateIn!.formatDateddMMyyyy}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Expected Check-out Date:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(
                    model.expectedCheckoutDate != null ? '${model.expectedCheckoutDate!.formatDateddMMyyyy}' : '--',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Speedo Reading:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.speedoReading}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("SWD Reading:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.swdReading}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text("Handed Over By:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.handedBy}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child:
                    Text('Time:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text(
                    model.expectedCheckoutTime == null
                        ? '--'
                        : '${model.expectedCheckoutTime?.formatDateTime('hh:mm a')}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Attended By:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('${model.attender}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).primaryColor,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          onPressed: () async {
            final servicingId = widget.service?.id;
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckOutFormScreen(
                    servicingId: servicingId,
                    checkInType: widget.service!.maintenanceType,
                    workCentreData: model.workCenter,
                  ),
                ));
            _fetchVehicleServicing();
          },
          child: Text(
            "Check Out",
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
            final servicingId = widget.service!.id;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewLogScreen(
                  servicingId: servicingId,
                ),
              ),
            );
          },
          child: Text(
            "View Update Logs",
            style: TextStyle(color: Theme.of(context).primaryColor),
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
            print("Maintenance Type: ${widget.service!.maintenanceType}");
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PreventiveCheckInFormScreen(
                  maintenanceType: widget.service!.maintenanceType,
                ),
              ),
            );
          },
          child: Text(
            "Schedule Another Maintenance",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      )
    ];

    return [...myChildren, ...newList];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MID ${widget.service!.vehicle != null ? widget.service!.vehicle!.vehicleNumber : ''}',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // elevation: 5,
      ),
      body: StreamBuilder<VehicleServicingDetailModel>(
        stream: _vehicleServicingModel,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: _buildChildren(snapshot.data!)),
            ),
          );
        },
      ),
    );
  }
}
