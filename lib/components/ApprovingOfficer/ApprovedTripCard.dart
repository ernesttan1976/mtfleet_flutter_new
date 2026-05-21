import 'package:flutter/material.dart';

class ApprovedTripCard extends StatelessWidget {
  final dynamic tripData;

  const ApprovedTripCard({Key? key, this.tripData}) : super(key: key);

  bool allDestinationCompleted() {
    int totalAccpetedDestination = 0;
    int totalCompletedDestination = 0;

    for (var des in tripData['destinations']) {
      totalAccpetedDestination = totalAccpetedDestination + 1;
      if (des['status'] == "Completed") {
        totalCompletedDestination = totalCompletedDestination + 1;
      }
    }

    for (var des in tripData['ad_hoc_destinations']) {
      if (des['approvalStatus'] == "Approved") {
        if (des['status'] != "Completed") {
          totalCompletedDestination = totalCompletedDestination + 1;
        }
      }
    }

    print(totalAccpetedDestination == totalCompletedDestination);

    return totalAccpetedDestination == totalCompletedDestination;
  }

  List<Widget> _buildChildren(var context) {
    bool check = allDestinationCompleted();
    String tripStatus = "";
    Color? statusColor;

    if (check) {
      tripStatus = "COMPLETED";
      statusColor = Colors.green;
    } else if (!tripData['isTripStarted']) {
      tripStatus = "NOT STARTED";
      statusColor = Colors.grey;
    } else {
      tripStatus = "IN PROGRESS";
      statusColor = Colors.orange[500];
    }

    var myList = [
      Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: <Widget>[
            Text(
              "Driver Name:",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Spacer(),
            Text(
              tripStatus,
              style: TextStyle(color: statusColor),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Text(
          "${tripData['driver']['name']}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Text(
          "Vehicle Number Plate:",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Text(
          "${tripData['vehicle'] != null ? tripData['vehicle']['vehicleNumber'] : 'N/A'}",
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Text(
          "Date:",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Text(
          "${tripData['tripDate']}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ];
    if (tripData['mt_rac_form'] != null) {
      var overAllRisk = tripData['mt_rac_form']['overallRisk'];
      Color myColor;
      if (overAllRisk == "MEDIUM") {
        myColor = Colors.orange[500]!;
      } else if (overAllRisk == "LOW") {
        myColor = Colors.green;
      } else {
        myColor = Colors.red[500]!;
      }
      myList.addAll([
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Text(
            "Risk Assesment",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Text("${tripData['mt_rac_form']['overallRisk']}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: myColor, fontWeight: FontWeight.bold)),
        )
      ]);
    }

    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildChildren(context),
    );
  }
}
