import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/util/checkListArray.dart';

import '../../components/components.dart';

class CheckListScreen extends StatefulWidget {
  final Function onPrev;
  final int index;
  final String overAllRisk;
  final Function onSubmit;

  const CheckListScreen({
    Key? key,
    required this.index,
    required this.onPrev,
    required this.overAllRisk,
    required this.onSubmit,
  }) : super(key: key);

  @override
  CheckListScreenState createState() => CheckListScreenState();
}

class CheckListScreenState extends State<CheckListScreen> with AutomaticKeepAliveClientMixin {
  String? checkListFor;
  final GlobalKey<FormBuilderState> _frontPassengerCheckListFormKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _vehicleCommanderFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  void _onChanged(value) {
    setState(() {
      checkListFor = value;
    });
  }

  void submissionFormAlert(var data) {
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
          content: const Text(
            "Are you sure to submit this trip form ?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width * 1.0,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.onSubmit(data);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildChildrenFront() {
    Color? myColor;
    if (widget.overAllRisk == "MEDIUM") {
      myColor = Colors.orange[500];
    } else if (widget.overAllRisk == "LOW") {
      myColor = Colors.green;
    } else {
      myColor = Colors.red[500];
    }

    var listofWidgets = [
      FormBuilder(
        key: _frontPassengerCheckListFormKey,
        child: Column(
          children: <Widget>[
            TitleAndWidgetShadow(
              title: 'Filled up by',
              child: FormBuilderDropdown(
                name: "filledBy",
                initialValue: checkListFor,
                onChanged: _onChanged,
                hint: Text('Filled by'),
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                items: ['Front Passenger', 'Vehicle Commander']
                    .map((filledBy) => DropdownMenuItem(value: filledBy, child: Text(filledBy)))
                    .toList(),
                icon: const Icon(Icons.expand_more),
              ),
            ),
            20.verticalSpace,
            Row(
              children: <Widget>[
                Text('Overall Risk:', style: _themeData.textTheme.bodyText1!.semiBold),
              ],
            ),
            20.verticalSpace,
            Text(
              widget.overAllRisk,
              style: _themeData.textTheme.headline4?.copyWith(color: myColor),
            ),
            20.verticalSpace,
            Row(
              children: <Widget>[
                Text('Checklist:', style: _themeData.textTheme.bodyText1!.semiBold),
              ],
            ),
            16.verticalSpace,
            if (checkListFor != null)
              FormBuilderCheckboxGroup(
                name: 'passenger_checklist',
                activeColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                options: [
                  FormBuilderFieldOption(
                    value: frontPassengerCheckList[0]['title'] as String,
                  ),
                  FormBuilderFieldOption(value: frontPassengerCheckList[1]['title'] as String),
                  FormBuilderFieldOption(value: frontPassengerCheckList[2]['title'] as String),
                  FormBuilderFieldOption(value: frontPassengerCheckList[3]['title'] as String),
                  FormBuilderFieldOption(value: frontPassengerCheckList[4]['title'] as String),
                  FormBuilderFieldOption(value: frontPassengerCheckList[5]['title'] as String),
                  FormBuilderFieldOption(value: frontPassengerCheckList[6]['title'] as String),
                ],
              ),
            20.verticalSpace,
            TitleAndWidgetShadow(
              title: 'Front Passenger’s Rank & Name',
              child: FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                name: "rankAndName",
                decoration: InputDecoration(
                    hintText: "Type here...",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              ),
            ),
            20.verticalSpace,
            TitleAndWidgetShadow(
              title: 'Front Passenger’s Last 4 Charaters of NRIC eg:378A',
              child: FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                name: "personalPin",
                decoration: InputDecoration(
                    hintText: "123A",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              )),
              side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
            ),
            onPressed: () {
              if (_frontPassengerCheckListFormKey.currentState!.saveAndValidate()) {
                submissionFormAlert(_frontPassengerCheckListFormKey.currentState!.value);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.black),
            ),
          ))
    ];

    return listofWidgets;
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
    var listofWidgets = [
      FormBuilder(
        key: _vehicleCommanderFormKey,
        child: Column(
          children: <Widget>[
            TitleAndWidgetShadow(
              title: 'Filled up by',
              child: FormBuilderDropdown(
                name: "filledBy",
                onChanged: _onChanged,
                initialValue: checkListFor,
                hint: Text('Filled by'),
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                items: ['Front Passenger', 'Vehicle Commander']
                    .map((filledBy) => DropdownMenuItem(value: filledBy, child: Text(filledBy)))
                    .toList(),
                icon: const Icon(Icons.expand_more),
              ),
            ),
            20.verticalSpace,
            Row(
              children: <Widget>[
                Text('Overall Risk:', style: _themeData.textTheme.bodyText1!.semiBold),
              ],
            ),
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.overAllRisk,
                  style: _themeData.textTheme.headline4?.copyWith(color: myColor),
                ),
              ],
            ),
            20.verticalSpace,
            Row(
              children: <Widget>[
                Text('Checklist:', style: _themeData.textTheme.bodyText1!.semiBold),
              ],
            ),
            16.verticalSpace,
            if (checkListFor != null)
              FormBuilderCheckboxGroup(
                name: "commander_checklist",
                activeColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                options: [
FormBuilderFieldOption(
   value: commanderCheckList[0]['title'] as String,
 ),
                  FormBuilderFieldOption(value: commanderCheckList[1]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[2]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[3]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[4]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[5]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[6]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[7]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[8]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[9]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[10]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[11]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[12]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[13]['title'] as String),
                  FormBuilderFieldOption(value: commanderCheckList[14]['title'] as String),
                  // FormBuilderFieldOption(
                  //     value: "${commanderCheckList[15]['title']}"),
                ],
              ),
            20.verticalSpace,
            TitleAndWidgetShadow(
              title: 'Vehicle Commander’s Rank & Name',
              child: FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                name: "rankAndName",
                decoration: InputDecoration(
                    hintText: "Type here...",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              ),
            ),
            20.verticalSpace,
            TitleAndWidgetShadow(
              title: 'Vehicle Commander’s Last 4 Charaters of NRIC eg:378A',
              child: FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                name: "personalPin",
                decoration: InputDecoration(
                  hintText: "123A",
                ),
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: !isLoading
            ? OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () {
                  if (_vehicleCommanderFormKey.currentState!.saveAndValidate()) {
                    submissionFormAlert(_vehicleCommanderFormKey.currentState!.value);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      )
    ];
    return listofWidgets;
  }

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    super.build(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                widget.onPrev(widget.index - 1);
              })
          // elevation: 5,
          ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (checkListFor != null)
              Text(
                'For $checkListFor',
                style: _themeData.textTheme.headline5!.text244F4E.semiBold,
              ),
            15.verticalSpace,
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: checkListFor == "Front Passenger" ? _buildChildrenFront() : _buildChildrenVehicle(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
