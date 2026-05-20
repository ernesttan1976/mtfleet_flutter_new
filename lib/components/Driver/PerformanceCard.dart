import 'package:flutter/material.dart';

class PerformanceCard extends StatefulWidget {
  const PerformanceCard({Key? key}) : super(key: key);

  @override
  _PerformanceCardState createState() => new _PerformanceCardState();
}

class _PerformanceCardState extends State<PerformanceCard> {
  // QuizCard()

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(40, 10, 0, 10),
          width: MediaQuery.of(context).size.width * 1.0,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check_circle,
                            size: 70,
                            color: Colors.lightBlueAccent[200],
                          ),
                        ),
                        Text("3k Bonus"),
                        Text("Done!")
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check_circle,
                            size: 70,
                            color: Colors.lightBlueAccent[200],
                          ),
                        ),
                        Text("6k Bonus"),
                        Text("Done!")
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.pie_chart,
                            size: 70,
                            color: Colors.lightBlueAccent[200],
                          ),
                        ),
                        Text("9k Bonus"),
                        Text("255km Left!")
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
