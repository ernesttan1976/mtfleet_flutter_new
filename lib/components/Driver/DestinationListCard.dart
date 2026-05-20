import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';

class DestinationListCard extends StatelessWidget {
  final Destination destinationData;
  final Function startDestination;
  final Function endDestination;
  final bool showStart;

  const DestinationListCard(
      {Key? key,
      required this.destinationData,
      required this.startDestination,
      required this.endDestination,
      this.showStart = false})
      : super(key: key);

  // Review
  // InProgress
  // InActive
  // Completed

  List<Widget> _buildChildren(var context) {
    var myList = [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${destinationData.to}",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Spacer(),
          destinationData.status == "Inactive"
              ? (showStart
                  ? InkWell(
                      onTap: () {
                        debugPrint("Start Called");
                        return startDestination();
                      },
                      child: Text(
                        'Start',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(decoration: TextDecoration.underline, letterSpacing: 1.0),
                      ),
                    )
                  : const SizedBox())
              : InkWell(
                  onTap: () {
                    if (destinationData.approvalStatus != null) {
                      if (destinationData.approvalStatus == "Approved") {
                        if (destinationData.status == "Inactive") {
                          startDestination.call();
                        } else if (destinationData.status == "InProgress") {
                          endDestination(destinationData.id, true);
                        }
                      }
                    } else {
                      if (destinationData.status == "Inactive") {
                        startDestination.call();
                      } else if (destinationData.status == "InProgress") {
                        endDestination(destinationData.id, false);
                      }
                    }
                  },
                  child: Text(
                    destinationData.approvalStatus != null
                        ? destinationData.approvalStatus == "Approved"
                            ? destinationData.status == "Inactive"
                                ? "Start"
                                : destinationData.status == "InProgress"
                                    ? "End"
                                    : "Completed"
                            : destinationData.approvalStatus!
                        : destinationData.status == "Inactive"
                            ? "Start"
                            : destinationData.status == "InProgress"
                                ? "End"
                                : "Completed",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(decoration: TextDecoration.underline, letterSpacing: 1.0),
                  ),
                ),
        ],
      ),
    ];

    var newList = <Widget>[];
    if (destinationData.status == "InProgress") {
      newList = [
        Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.topLeft,
          child: Text(
            "Start time: ${destinationData.eLog?.startTime?.formatDateTime('HH:mm') ?? ''}",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        )
      ];
    }
    if (destinationData.status != "InProgress" && destinationData.status != "Inactive") {
      newList = [
        Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.topLeft,
          child: Text(
            "Start time: ${destinationData.eLog?.startTime?.formatDateTime('HH:mm') ?? ''}",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          alignment: Alignment.topLeft,
          child: Text(
            "End time: ${destinationData.eLog?.endTime?.formatDateTime('HH:mm') ?? ''}",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        )
      ];
    }

    return [...myList, ...newList];
  }

  @override
  Widget build(BuildContext context) {
    print("Destination Data $destinationData");
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(12.0),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: _buildChildren(context),
          ),
        ),
      ),
    );
  }
}
