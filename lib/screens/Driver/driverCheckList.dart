import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:transport_flutter/util/checkListArray.dart';

class DriverCheckList extends StatefulWidget {
  final Function onPrev;
  final Function onNext;
  final int index;
  final String overAllRisk;
  final bool isVehicleCommander;
  final Function onSubmit;

  DriverCheckList({
    Key? key,
    required this.index,
    required this.onPrev,
    required this.onNext,
    required this.overAllRisk,
    required this.isVehicleCommander,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _DriverCheckListState createState() => _DriverCheckListState();
}

class _DriverCheckListState extends State<DriverCheckList> with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _driverFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  void submissionFormAlert(Map<String, dynamic> value) {
    showDialog(
      context: context,
      // barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You clicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
              child: Text(
            "Are you sure to submit this trip form ?",
            textAlign: TextAlign.center,
          )),
          actions: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.onSubmit(value);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        );
      },
    );
  }

  List<Widget> _buildChildrenVehicle() {
    Color? myColor;
    if (widget.overAllRisk == "HIGH") {
      myColor = Colors.red[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.orange[500];
    }
    var listofWidgets = <Widget>[
      FormBuilder(
        key: _driverFormKey,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text('Overall Risk:',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold))),
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
                  style: Theme.of(context).textTheme.headline4!.copyWith(color: myColor),
                ))),
              ],
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Row(
              children: <Widget>[
                Container(
                  child: Flexible(
                      child: Text('Checklist:',
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            FormBuilderCheckboxGroup(
              name: "driver_checklist",
              activeColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              options: [
                FormBuilderFieldOption(
                  value: "${driverCheckList[0]['title']}",
                ),
                FormBuilderFieldOption(value: "${driverCheckList[1]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[2]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[3]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[4]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[5]['title']}"),
                FormBuilderFieldOption(value: "${driverCheckList[6]['title']}"),
              ],
            ),
          ],
        ),
      ),
    ];

    if (widget.isVehicleCommander) {
      listofWidgets.add(Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: !isLoading
            ? OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () {
                  if (_driverFormKey.currentState!.saveAndValidate()) {
                    widget.onNext(widget.index + 1, _driverFormKey.currentState!.value);
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.black),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ));
    } else {
      listofWidgets.add(Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: !isLoading
            ? OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () {
                  if (_driverFormKey.currentState!.saveAndValidate()) {
                    submissionFormAlert(_driverFormKey.currentState!.value);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ));
    }

    return listofWidgets;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(
              'For Driver',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            leading: IconButton(
                // alignment: Alignment.topLeft,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onPrev(widget.index - 1);
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
                    children: _buildChildrenVehicle(),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
