import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/screens/ApprovingOfficer/MTRACApprovalThree.dart';

export 'package:transport_flutter/components/extension/extension.dart';

class MTRACApprovalSecondScreen extends StatelessWidget {
  final TripDetailModel? tripModel;

  const MTRACApprovalSecondScreen({Key? key, this.tripModel}) : super(key: key);

  List<Widget> _buildChildren(var context) {
    Color? myColor;
    if (tripModel?.mtracForm?.overAllRisk == "MEDIUM") {
      myColor = Colors.orange[500];
    } else if (tripModel?.mtracForm?.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.red[500];
    }

    var myList = [
      Row(
        children: <Widget>[
          Container(
            child: Flexible(
                child: Text('Overall Risk:',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold))),
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
            "${tripModel?.mtracForm?.overAllRisk}",
            style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: myColor,
                ),
          ))),
        ],
      ),
      Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
      ...(tripModel?.mtracForm?.quizzes ?? []).map(
        (e) => _buildTitleAndContent(context, title: e.question, content: e.answer),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 50),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MTRACApprovalThirdScreen(
                  tripModel: tripModel,
                ),
              ),
            );
          },
          child: Text(
            "Next",
            style: TextStyle(color: Colors.black),
          ),
        ),
      )
    ];

    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'MT RAC Form Approval',
              style: Theme.of(context).textTheme.headline5?.text244F4E.semiBold,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildChildren(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndContent(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$title:', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold)),
        Text('${content}', style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal)),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
