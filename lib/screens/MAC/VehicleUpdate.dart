import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';

class VehicleUpdateScreen extends StatefulWidget {
  final dynamic servicingID;
  final dynamic currentUpdates;

  const VehicleUpdateScreen({Key? key, this.servicingID, this.currentUpdates}) : super(key: key);

  @override
  VehicleUpdateScreenState createState() => VehicleUpdateScreenState();
}

class VehicleUpdateScreenState extends State<VehicleUpdateScreen> {
  final dioClient = AuthedDio.instance.dio;
  final GlobalKey<FormBuilderState> _vehicleUpdateFormKey = GlobalKey<FormBuilderState>();

  bool submitButtonLoading = false;

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  void onSubmitForm(Map<String, dynamic> data) async {
    setState(() {
      submitButtonLoading = true;
    });
    try {
      print(data);
      final dataMap = <String, dynamic>{
        "dateOfCompletion": (data['dateOfCompletion'] as DateTime).toUtc().toIso8601String(),
        "vehicleServicingId": widget.servicingID,
        "notes": data['notes'],
      };

      var dataJSON = jsonEncode(dataMap, toEncodable: myEncode);

      print(dataJSON);
      var dio = await dioClient;
      var response = await dio.post("/check-in/update-logs", data: dataJSON);
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", "Log updated successfully!");
      } else {
        showAlertDialog(context, "Error", response.data['message'], isPop: false);
      }
    } catch (e) {
      setState(() {
        submitButtonLoading = false;
      });
      showAlertDialog(context, "Error", e.toString(), isPop: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Log',
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
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: <Widget>[
                      FormBuilder(
                        key: _vehicleUpdateFormKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: FormBuilderTextField(
                                minLines: 3,
                                name: "notes",
                                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                                decoration: InputDecoration(
                                    hintText: "Type Here",
                                    labelText: "Update Notes",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.black)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: FormBuilderDateTimePicker(
                                  name: "dateOfCompletion",
                                  inputType: InputType.date,
                                  decoration: InputDecoration(
                                      labelText: "Expected Check-out Date",
                                      labelStyle:
                                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                                        child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                                      )),
                                  initialValue: DateTime.now(),
                                  format: DateFormat('dd MMMM yyyy')),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: submitButtonLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : OutlinedButton(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  )),
                                  side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                                ),
                                onPressed: () {
                                  if (_vehicleUpdateFormKey.currentState!.saveAndValidate()) {
                                    onSubmitForm(_vehicleUpdateFormKey.currentState!.value);
                                  }
                                },
                                child: Text(
                                  "Update",
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
