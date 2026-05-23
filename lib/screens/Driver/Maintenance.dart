import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import "package:transport_flutter/constants.dart" as constants;
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/request.dart' as request_util;

class MaintenanceScreen extends StatefulWidget {
  final VehicleServicingModel service;

  const MaintenanceScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final request = request_util.Request();
  final dioClient = AuthedDio.instance.dio;
  final vehicleServicingModel = BehaviorSubject<VehicleServicingDetailModel>();

  @override
  void initState() {
    super.initState();
    _fetchVehicleServicing();
  }

  void _fetchVehicleServicing() async {
    try {
      final res = await request.get(Uri.parse('check-in/${widget.service.vehicleId}'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final decodedBody = json.decode(res.body);
        final model = VehicleServicingDetailModel.fromJson(decodedBody);
        vehicleServicingModel.add(model);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase ?? 'Unknown error');
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
  }

  List<Widget> _buildChildren(VehicleServicingDetailModel model) {
    var myChildren = [
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              widget.service.maintenanceType == "AVI"
                  ? 'Type of Maintenance : Annual Vehicle Inspection '
                  : 'Type of Maintenance : ${widget.service.maintenanceType}',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "Work Center",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.workCenter,
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
              "Telephone No",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.telephoneNo,
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
              'Vehicle Number:',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              widget.service.vehicle?.vehicleNumber ?? '',
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
              'Model',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              widget.service.vehicle?.model ?? '',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    ];

    if (widget.service.maintenanceType == "Preventive") {
      myChildren.addAll([
        const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'Type of Preventive Maintenance',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                widget.service.maintenanceType,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        )
      ]);
    }

    var newList = [
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "Fuel Sensor Tag",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.frontSensorTag,
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
              "Basic Issue Tools:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      if (model.basicIssueTools.isNotEmpty)
        for (var tool in model.basicIssueTools)
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  '${tool.name}: ${tool.quantity}',
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
      if (model.basicIssueTools.isEmpty)
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'None',
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
              "Condition of Vehicle:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        height: model.images.isNotEmpty ? 200 : 30,
        child: model.images.isNotEmpty
            ? ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (var pic in model.images)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: CachedNetworkImage(
                        imageUrl: "${constants.SERVER_URI_API}${pic.path}",
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                ],
              )
            : Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      'No Images Found!',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              widget.service.maintenanceType == "Corrective" ? "Corrective Maintenance:" : "Defect:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              widget.service.maintenanceType == "Corrective"
                  ? model.correctiveMaintenance?.correctiveMaintenance ?? '--'
                  : "s",
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
              "Date In:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.dateIn == null ? '--' : model.dateIn!.formatDateddMMyyyy,
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
              "Expected Check-out Date:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.expectedCheckoutDate != null ? model.expectedCheckoutDate!.formatDateddMMyyyy : '--',
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
              "Speedo Reading:",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.speedoReading.toString(),
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
              "SWD Reading:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.swdReading.toString(),
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
              "Handed Over By:",
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.handedBy,
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
              'Time:',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.expectedCheckoutTime == null
                  ? '--'
                  : model.expectedCheckoutTime!.formatDateTime('hh:mm a'),
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
              'Attended By:',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              model.attender,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      )
    ];

    return [...myChildren, ...newList];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MID ${widget.service.vehicle != null ? widget.service.vehicle!.vehicleNumber : ''}',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<VehicleServicingDetailModel>(
        stream: vehicleServicingModel,
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
