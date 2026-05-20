import 'package:flutter/material.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/trip_driver_model.dart';

class PendingTripCard extends StatelessWidget {
  final TripDriverModel tripData;

  const PendingTripCard({Key? key, required this.tripData}) : super(key: key);

  List<Widget> _buildChildren(var context) {
    Color? riskColor;
    if (tripData.riskAssessment != null) {
      switch (tripData.riskAssessment) {
        case 'LOW':
          riskColor = Colors.green;
          break;
        case 'HIGH':
          riskColor = Colors.red;
          break;
        case 'MEDIUM':
          riskColor = Colors.orange[500]!;
          break;
        default:
          riskColor = Colors.green;
          break;
      }
    }
    var myList = [
      Text(
        "Driver Name:",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      5.verticalSpace,
      Text(
        "${tripData.driverName}",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      10.verticalSpace,
      Text(
        "Vehicle Number Plate:",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      5.verticalSpace,
      Text(
        "${tripData.vehicleNumber}",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      10.verticalSpace,
      Text(
        "Date:",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      5.verticalSpace,
      Text(
        tripData.tripDate!.formatDateTime('yyyy-MM-dd'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      10.verticalSpace,
      if (tripData.riskAssessment != null)
        Text(
          "Risk Assesment:",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      5.verticalSpace,
      if (tripData.riskAssessment != null)
        Text(
          tripData.riskAssessment!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: riskColor),
        ),
    ];

    // if (tripData['mt_rac_form'] != null) {
    //   var overAllRisk = tripData['mt_rac_form']['overallRisk'];
    //   Color myColor;
    //   if (overAllRisk == "MEDIUM") {
    //     myColor = Colors.orange[500];
    //   } else if (overAllRisk == "LOW") {
    //     myColor = Colors.green;
    //   } else {
    //     myColor = Colors.red[500];
    //   }
    //   myList.addAll([
    //     Container(
    //       padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
    //       child: Text(
    //         "Risk Assesment",
    //         style: Theme.of(context).textTheme.bodyLarge,
    //       ),
    //     ),
    //     Container(
    //       padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
    //       child: Text("${tripData['mt_rac_form']['overallRisk']}",
    //           style: Theme.of(context)
    //               .textTheme
    //               .bodyText1
    //               .copyWith(color: myColor, fontWeight: FontWeight.bold)),
    //     )
    //   ]);
    // }

    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildChildren(context),
    ).paddingAll(15);
  }
}
