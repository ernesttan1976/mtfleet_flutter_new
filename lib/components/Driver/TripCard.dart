import 'package:flutter/material.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class TripCard extends StatelessWidget {
  final TripDriverModel tripData;

  const TripCard({Key? key, required this.tripData}) : super(key: key);

  // Approved
  // Rejected
  // Pending
  // Draft
  List<Widget> _buildChildren(var context) {
    Color statusColor;
    Color? riskColor;
    switch (tripData.approvalStatus) {
      case 'Approved':
        statusColor = Color(0xff60D7D4);
        break;
      case 'Rejected':
        statusColor = Color(0xffD76060);
        break;
      case 'Pending':
        statusColor = Color(0xffD7AF60);
        break;
      case 'Draft':
        statusColor = Color(0xffCBCBCB);
        break;
      default:
        statusColor = Color(0xffD76060);
        break;
    }
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

    var myData = [
      Row(
        children: <Widget>[
          Text(
            "Date:",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            (tripData.approvalStatus == 'Approved' && tripData.tripStatus != 'Inactive' ? tripData.tripStatus : tripData.approvalStatus)
                .toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
          )
        ],
      ),
      Text(
        (tripData.tripDate ?? DateTime.now()).formatDateTime('dd MMM yyyy'),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      20.verticalSpace,
      Text(
        "Destination",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      ...tripData.destinations.map(
        (e) => Text(
          e.to,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      20.verticalSpace,
      if (tripData.riskAssessment != null)
        Text(
          "Risk Assessment",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      5.verticalSpace,
      if (tripData.riskAssessment != null)
        Text(
          tripData.riskAssessment!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: riskColor),
        ),
    ];

    return myData;
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
