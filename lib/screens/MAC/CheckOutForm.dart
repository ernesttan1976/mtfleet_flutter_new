import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';

class CheckOutFormScreen extends StatefulWidget {
  final servicingId;
  final String? checkInType;
  final String? workCentreData;

  const CheckOutFormScreen({Key? key, @required this.servicingId, this.checkInType, this.workCentreData})
      : super(key: key);

  @override
  _CheckOutFormScreenState createState() => _CheckOutFormScreenState();
}

class _CheckOutFormScreenState extends State<CheckOutFormScreen> {
  final GlobalKey<FormBuilderState> _checkOutFormKey = GlobalKey<FormBuilderState>();
  List listOfItems = [];
  int toolsCount = 1;
  var submitting = false;
  bool itemSet = false;
  final dioClient = AuthedDio.instance.dio;

  void onToolRemove(index) {
    setState(() {
      listOfItems[index] = null;
    });
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  // Add New Item fields in list
  void addNewItem() {
    print("The Length of List is ${listOfItems.length}");
    int index = listOfItems.length;
    setState(() {
      listOfItems.add(
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                width: MediaQuery.of(context).size.width * 0.4,
                child: FormBuilderTextField(
                  key: Key("$index"),
                  validator:
                      FormBuilderValidators.compose([FormBuilderValidators.required(errorText: "Cannot be empty!")]),
                  name: "name$index",
                  controller: new TextEditingController(),
                  decoration: InputDecoration(
                    hintText: "Type Here...",
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                child: FormBuilderTextField(
                  key: Key("$index"),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Cannot be empty!"),
                    FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                    FormBuilderValidators.min(1, errorText: "Must be > 0!")
                  ]),
                  name: "quantity$index",
                  controller: new TextEditingController(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "Type Here",
                      counterStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 4.0, color: Colors.black)),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                width: MediaQuery.of(context).size.width * 0.1,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => onToolRemove(index),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // On Submit Checkout Form
  void onSubmitForm(var data) async {
    try {
      setState(() {
        submitting = true;
      });

      List names = [];
      List quantities = [];

      data.entries.forEach((e) {
        if (e.key.contains("name")) {
          names.add(e.value);
        } else if (e.key.contains("quantity")) {
          quantities.add(e.value);
        }
      });

      // List of Tools
      List basicIssueTools = [];

      for (var i = 0; i < names.length; i++) {
        if (listOfItems[i] != null) basicIssueTools.add({"name": names[i], "quantity": int.parse(quantities[i])});
      }

      var dio = await dioClient;

      final _typeData = {};

      if (widget.checkInType == 'Preventive') {
        _typeData.addAll({
          "preventiveMaintenance": {
            "nextServicingDate": data['nextServicingDate'].toUtc().toIso8601String(),
            "nextServicingMileage": int.parse(data['nextServicingMileage'])
          }
        });
      }
      if (widget.checkInType == 'Corrective') {
        _typeData.addAll({
          "correctiveMaintenance": {"correctiveMaintenance": data['correctiveMaintenance']}
        });
      }
      if (widget.checkInType == 'AVI') {
        _typeData.addAll({
          "annualVehicleInspection": {"nextAVIDate": data['nextAVIDate'].toUtc().toIso8601String()},
        });
      }

      // final _data = {
      //   "dateOut": data['dateOut'].toUtc().toIso8601String(),
      //   "speedoReading": data['speedoReading'],
      //   "swdReading": data['swdReading'],
      //   "time": data['time'].toUtc().toIso8601String(),
      //   "remark": data['remark'],
      //   "attendedBy": data['attendedBy'],
      //   "workCenter": widget.workCentreData,
      //   "vehicleTakenOver": data['vehicleTakenOver'],
      //   "checkOutType": widget.checkInType,
      //   "basicIssueTools": basicIssueTools.toList(),
      //   ..._typeData,
      //   "vehicleServicing": widget.servicingId
      // };
      final _data = {
        "dateOut": data['dateOut'].toUtc().toIso8601String(),
        "speedoReading": data['speedoReading'],
        "swdReading": data['swdReading'],
        "time": data['time'].toUtc().toIso8601String(),
        "remark": data['remark'],
        "attendedBy": data['attendedBy'],
        "workCenter": widget.workCentreData,
        "vehicleTakenOver": data['vehicleTakenOver'],
        "checkOutType": widget.checkInType,
        "basicIssueTools": basicIssueTools.toList(),
        ..._typeData,
        "vehicleServicing": widget.servicingId
      };
      print(_data);
      print(json.encode(_data));
      final response = await dio.post("/check-out", data: json.encode(_data));
      setState(() {
        submitting = false;
      });
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", response.statusMessage);
      } else {
        showAlertDialog(context, "Failure", response.statusMessage, isPop: false);
      }
    } catch (e) {
      setState(() {
        submitting = false;
      });
      showAlertDialog(context, "Failure", e, isPop: false);
    }
  }

  void setMyItem(var context) {
    if (!itemSet) {
      setState(() {
        listOfItems.add(
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: FormBuilderTextField(
                    validator:
                        FormBuilderValidators.compose([FormBuilderValidators.required(errorText: "Cannot be empty!")]),
                    name: "name",
                    decoration: InputDecoration(
                      hintText: "Type Here...",
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                  child: FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: "Cannot be empty!"),
                      FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                      FormBuilderValidators.min(1, errorText: "Must be > 0!")
                    ]),
                    name: "quantity",
                    controller: new TextEditingController(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Type Here",
                        counterStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 4.0, color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        );
      });
    }
    setState(() {
      itemSet = true;
    });
  }

  List<Widget> _buildChildren() {
    var listOfWidget = [];
    if (widget.checkInType == "Preventive") {
      listOfWidget.addAll([
        Padding(
          padding: EdgeInsets.all(10),
          child: FormBuilderDateTimePicker(
              name: "nextServicingDate",
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              inputType: InputType.date,
              decoration: InputDecoration(
                  labelText: "Next Servicing Date",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
                    child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                  )),
              initialValue: DateTime.now(),
              format: new DateFormat('dd MMMM yyyy')),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: FormBuilderTextField(
            name: "nextServicingMileage",
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "Next Servicing Mileage",
                hintText: "Type Here...",
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
          ),
        ),
      ]);
    }

    if (widget.checkInType == "AVI") {
      listOfWidget.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: FormBuilderDateTimePicker(
              name: "nextAVIDate",
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              inputType: InputType.date,
              decoration: InputDecoration(
                  labelText: "Next AVI Date",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12.0),
                    child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                  )),
              // initialValue: DateTime.now(),
              format: new DateFormat('dd MMMM yyyy')),
        ),
      );
    }

    listOfWidget.addAll([
      Container(
        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                "Basic Issue Tools",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child:
                  Text("OUT (Qty)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black)),
            )
          ],
        ),
      ),
    ]);

    var listOfWidget2 = [];

    for (var item in listOfItems) {
      if (item != null) {
        listOfWidget2.add(item);
      }
    }

    var listOfWidget3 = [
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            addNewItem();
          },
          child: Text(
            "Add Another Item",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderDateTimePicker(
          name: "dateOut",
          inputType: InputType.date,
          enabled: false,
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              labelText: "Date Out",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
              )),
          initialValue: DateTime.now(),
          format: new DateFormat('dd MMMM yyyy'),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderTextField(
          name: "speedoReading",
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              hintText: "Type Here..",
              labelText: "Speedo Reading",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderTextField(
          name: "swdReading",
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              labelText: "SWD Reading",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(5, 15, 5, 0),
        alignment: Alignment.centerLeft,
        child: Text(
          "Vehicle Taken Over By (Rank & Name)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 10, 10),
        child: FormBuilderTextField(
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          name: "vehicleTakenOver",
          decoration: InputDecoration(
              // labelText: "Vehicle Taken Over By (Rank & Name)",
              hintText: "Type Here...",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(5, 15, 5, 0),
        alignment: Alignment.centerLeft,
        child: Text(
          "Work Centre",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 10, 10),
        child: FormBuilderTextField(
          name: "workCentrer",
          initialValue: widget.workCentreData,
          readOnly: true,
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              hintText: "Type Here...",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderDateTimePicker(
          name: "time",
          enabled: false,
          inputType: InputType.time,
          decoration: InputDecoration(
              labelText: "Time",
              hintText: "HH-MM",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: Icon(Icons.access_time),
              )),
          format: new DateFormat('hh:mm'),
          initialValue: DateTime.now(),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderTextField(
          name: "remark",
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              labelText: "Remark",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: FormBuilderTextField(
          name: "attendedBy",
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          decoration: InputDecoration(
              labelText: "Attended By",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
          initialValue: "",
          // readOnly: true,
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: submitting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onPressed: () {
                  if (_checkOutFormKey.currentState!.saveAndValidate()) {
                    print(_checkOutFormKey.currentState!.value);
                    onSubmitForm(_checkOutFormKey.currentState!.value);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                ),
              ),
      ),
    ];

    return [...listOfWidget, ...listOfWidget2, ...listOfWidget3];
  }

  @override
  Widget build(BuildContext context) {
    setMyItem(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.checkInType == "Preventive"
                ? 'Preventive Check-Out Form'
                : widget.checkInType == "Corrective"
                    ? "Corrective Check-Out Form"
                    : "Annual Vehicle Inspection \nCheck-out Form",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          // elevation: 5,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        FormBuilder(
                          key: _checkOutFormKey,
                          child: Column(children: _buildChildren()),
                        )
                      ],
                    )),
              ),
            )
          ],
        ));
  }
}
