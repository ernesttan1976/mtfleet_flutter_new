import 'package:flutter/material.dart';

class RiskAccessmentScreen extends StatefulWidget {
  final Function? onPrev;
  final int? index;
  final Function? onNext;
  final bool? isVehicleCommander;
  final String? overAllRisk;

  const RiskAccessmentScreen({
    Key? key,
    this.index,
    this.onPrev,
    this.onNext,
    this.isVehicleCommander,
    this.overAllRisk,
  }) : super(key: key);

    @override
    RiskAccessmentScreenState createState() => RiskAccessmentScreenState();
}

class RiskAccessmentScreenState extends State<RiskAccessmentScreen> {
  bool isLoading = false;

  List<Widget> _buildChildren() {
    print("${widget.overAllRisk}");

    Color? myColor;
    if (widget.overAllRisk == "MEDIUM") {
      myColor = Colors.orange[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.red[500];
    }
    var listofWidgets = [
      Row(
        children: <Widget>[
          Flexible(
              child: Text(
            'Risk Assessment',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
          )),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Overall Risk:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Flexible(
                  child: Text(
            '${widget.overAllRisk}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: myColor),
          ))),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Risk Levels Explanation:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text.rich(
            TextSpan(
              text: 'LOW',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green), // default text style
              children: <TextSpan>[
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                  text: '  Risk - Normal operational risk ',
                )
              ],
            ),
          )),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text.rich(
            TextSpan(
              text: 'MEDIUM',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.orange[500]), // default text style
              children: <TextSpan>[
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                  text:
                      ' Risk - Above normal operational risk level. Increase supervision, briefing and exercise caution. Mission may be suspended till conditions are better ',
                )
              ],
            ),
          )),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text.rich(
            TextSpan(
              text: 'HIGH',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red[500]), // default text style
              children: <TextSpan>[
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                  text:
                      ' Risk - Do not proceed with mission unless approved by higher authorities. All high risk factors must be mitigated ',
                )
              ],
            ),
          )),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('Front Passenger Standing Order:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('1. Remind the driver to stay awake:', style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('2. Look out for sign of fatigue in the driver.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('3. Remind the driver not to speed or drive recklessly.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
      Row(
        children: <Widget>[
          Flexible(
              child: Text('4. Remind the driver not to use mobile device while the vehicle is in motion.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
    ];
    if (widget.isVehicleCommander!) {
      listofWidgets.addAll([
        Row(
        children: <Widget>[
          Flexible(
              child: Text('Vehicle Commander Standing Order:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(
              child: Text(
                  '1. To be responsible for the discipline and safety of all passengers/crew in the assigned transport detail.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(
              child: Text(
                  '2. To assist to look out fire obstruction, hazard or danger. if the driver is reversing, there is no requirement for the VC to dismount to guide the driver. However, VC should render assitance to the driver when requested.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(
              child: Text('3. Go through intended route with the driver.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(
              child: Text(
                  '4. If unsure of the route or lost, to instruct the driver to stop the vehicle at a safe place to re-orientate or seek further instruction.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(
              child: Text(
                  '5. If involved in an accident, to inform unit about the accident and assist the driver to manage the accident.',
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
        children: <Widget>[
          Flexible(child: Text('6. To check and endrose the MT-RAC.', style: Theme.of(context).textTheme.bodyLarge)),
        ],
        ),
        Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.88,
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: WidgetStateProperty.all<BorderSide>(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () {
                  widget.onNext!(widget.index! + 1);
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        )
      ]);
    } else {
      listofWidgets.add(Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: OutlinedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                )),
                side: WidgetStateProperty.all<BorderSide>(BorderSide(color: Theme.of(context).primaryColor)),
              ),
              onPressed: () {
                widget.onNext!(widget.index! + 1);
              },
              child: Text(
                "Next",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ));
      // listofWidgets.add(Row(
      //   children: <Widget>[
      //     Container(
      //       width: MediaQuery.of(context).size.width * 0.88,
      //       padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      //       child: !isLoading
      //           ? OutlineButton(
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(30.0),
      //               ),
      //               onPressed: () {
      //                 submissionFormAlert();
      //               },
      //               borderSide:
      //                   BorderSide(color: Theme.of(context).primaryColor),
      //               child: Text(
      //                 "Submit",
      //                 style: TextStyle(color: Colors.black),
      //               ),
      //             )
      //           : Center(
      //               child: CircularProgressIndicator(),
      //             ),
      //     )
      //   ],
      // ));
    }
    return listofWidgets;
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.overAllRisk == "NO MOVE") {
    //   cancelTripFormAlert();
    // }
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Risk Assessment',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
                // alignment: Alignment.topLeft,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onPrev!(widget.index! - 1);
                })
            // elevation: 5,
            ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: _buildChildren(),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
