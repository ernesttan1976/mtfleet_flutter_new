import 'package:flutter/material.dart';
import 'package:transport_flutter/models/models.dart';

class ApprovedTripDocScreen extends StatelessWidget {
  final TripDetailModel approvedTripData;

  const ApprovedTripDocScreen({Key? key, required this.approvedTripData}) : super(key: key);

  List<Widget> _buildChildren(var context) {
    print("Trip Data: $approvedTripData");
    var myList = [
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'Date:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '${approvedTripData.tripDate}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'Approving Officer Name:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              approvedTripData.approvingOfficer == null
                  ? "No Approving Officer"
                  : '${approvedTripData.approvingOfficer['name']}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "${approvedTripData.vehicle?.vehicleNumber}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "${approvedTripData.vehicle?.vehicleType}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
      for (var item in approvedTripData.destinations)
        Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'To:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    item.to,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    item.requisitionerPurpose,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ],
        ),
    ];
    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Approved Trip Form",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          // elevation: 5,
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
            )
          ],
        ));
  }
}
