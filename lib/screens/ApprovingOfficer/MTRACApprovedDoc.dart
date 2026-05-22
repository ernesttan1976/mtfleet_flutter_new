import 'package:flutter/material.dart';
import 'package:transport_flutter/models/trip_detail_model.dart';

class MTRACTripDocScreen extends StatelessWidget {
  final TripDetailModel approvedMTRACData;

  const MTRACTripDocScreen({Key? key, required this.approvedMTRACData}) : super(key: key);

  List<Widget> _buildChildren(var context) {
    print(approvedMTRACData);
    var myList = [];
    if (approvedMTRACData.mtracForm != null) {
      Color? myColor;
      if (approvedMTRACData.mtracForm?.overAllRisk == "MEDIUM") {
        myColor = Colors.orange[500];
      } else if (approvedMTRACData.mtracForm?.overAllRisk == "LOW") {
        myColor = Colors.green;
      } else {
        myColor = Colors.red[500];
      }

      myList.addAll([
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'Overall Risk:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                "${approvedMTRACData.mtracForm?.overAllRisk}",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: myColor,
                    ),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      ]);
    }

    if (approvedMTRACData.mtracForm!.isAdditionalDetailApplicable!) {
      myList.addAll([
        const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "Despatch Date",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "${approvedMTRACData.mtracForm?.despatchDate}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "Despatch Time",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "${approvedMTRACData.mtracForm?.despatchTime?.toIso8601String().substring(0, 5)}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "Release Date:",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "${approvedMTRACData.mtracForm?.relaseDate}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "Release Time:",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                "${approvedMTRACData.mtracForm?.relaseTime?.toIso8601String().substring(0, 5)}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ]);
    }

    myList.addAll([
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "Vehicle Commander:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              approvedMTRACData.vehicle == null
                  ? "No Vehicle Commander"
                  : "${approvedMTRACData.vehicle?.model}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "Safety Measure:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              approvedMTRACData.mtracForm?.safetyMeasures == null
                  ? "No Safety Measures"
                  : "${approvedMTRACData.mtracForm?.safetyMeasures}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    ]);

    return [...myList];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Approved MT RAC Form ",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SizedBox(
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: _buildChildren(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
