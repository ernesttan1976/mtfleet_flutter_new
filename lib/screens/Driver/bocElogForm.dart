import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';

import '../../components/components.dart';

class BOCELogBookFormScreen extends StatefulWidget {
  final dynamic tripData;
  final Function? onPrev;

  BOCELogBookFormScreen({Key? key, this.tripData, this.onPrev}) : super(key: key);

  @override
  _BOCELogBookFormScreenState createState() => _BOCELogBookFormScreenState();
}

class _BOCELogBookFormScreenState extends State<BOCELogBookFormScreen> {
  final GlobalKey<FormBuilderState> _bOCElogbookFormKey = GlobalKey<FormBuilderState>();

  dynamic startTime;
  bool _autovalidate = false;
  bool submitButtonLoading = false;
  int newTotalDistance = 0;

  final dioClient = AuthedDio.instance.dio;

  void onSubmit(var formData) async {
    setState(() {
      submitButtonLoading = true;
    });

    String formattedTime1 = DateFormat.Hm().format(widget.tripData['timeStarted']);
    String formattedTime2 = DateFormat.Hm().format(widget.tripData['timeArrived']);
    formData['startTime'] = formattedTime1 + ":00.000";
    formData['endTime'] = formattedTime2 + ":00.000";

    formData['totalDistance'] = "$newTotalDistance";
    formData['vehicleNumber'] = widget.tripData['vehicle'];
    var data = {
      "tripDate": widget.tripData['tripDate'].toIso8601String(),
      "vehicle": widget.tripData['vehicleID'],
      "requisitionerPurpose": widget.tripData['requisitionerPurpose'],
      "currentMeterReading": widget.tripData['intialmeterReading'],
      "driver": widget.tripData['driver'],
      "eLogData": formData
    };

    var dataJSON = jsonEncode(data, toEncodable: myEncode);
    print(dataJSON);
    var dio = await dioClient;
    var response = await dio.post("/boc-trips", data: dataJSON);

    if (response.statusCode == 200) {
      showAlertDialog(context, "Success", "Trip Added successfully!");
      setState(() {
        submitButtonLoading = false;
      });
    }
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          // elevation: 5,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ELogbook',
              style: _themeData.textTheme.headline5!.text244F4E.semiBold,
            ).paddingHorizontal(24),
            10.verticalSpace,
            Expanded(
              child: _buildContent(),
            )
          ],
        ));
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Trip Date', style: _themeData.textTheme.subtitle2!.semiBold),
          Text("${DateTime.now().toString().substring(0, 10)}", style: _themeData.textTheme.bodyText1),
          20.verticalSpace,
          Text('Time Started', style: _themeData.textTheme.subtitle2!.semiBold),
          Text("${DateTime.now().toString().substring(11, 16)}", style: _themeData.textTheme.bodyText1),
          20.verticalSpace,
          Text('Time Arrived', style: _themeData.textTheme.subtitle2!.semiBold),
          Text("${DateTime.now().toString().substring(11, 16)}", style: _themeData.textTheme.bodyText1),
          20.verticalSpace,
          FormBuilder(
            key: _bOCElogbookFormKey,
            autovalidateMode: _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: Column(
              children: <Widget>[
                TitleAndWidgetShadow(
                  title: 'Stationary Running Time(in minutes)',
                  child: FormBuilderTextField(
                    name: "stationaryRunningTime",
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ]),
                    decoration: InputDecoration(
                      hintText: "Type here...",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                20.verticalSpace,
                TitleAndWidgetShadow(
                  title: 'Meter Reading At Journey’s End (if not working, write “ N,W, ”)',
                  child: FormBuilderTextField(
                    name: "meterReading",
                    onChanged: (value) {
                      if (value?.length == 0) {
                        setState(() {
                          newTotalDistance = 0;
                        });
                      }
                      if (value!.length > 0) {
                        setState(() {
                          newTotalDistance = 1;
                        });
                      }
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(100, errorText: "Must be > 100!")
                    ]),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Type here..."),
                  ),
                ),
                20.verticalSpace,
                TitleAndWidgetShadow(
                  title: 'Total Distance in KM',
                  child: TextFormField(
                    enabled: false,
                    controller: new TextEditingController(text: '$newTotalDistance'),
                    decoration: InputDecoration(hintText: 'System calculated'),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: FormBuilderTextField(
                //     minLines: 3,
                //     name: "fuelReceived",
                //     validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                //     decoration: InputDecoration(
                //         hintText: "Type Here",
                //         labelText: "Fuel Received",
                //         labelStyle: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 20.0,
                //             color: Colors.black)),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: FormBuilderDropdown(
                //     name: "fuelType",
                //     decoration: InputDecoration(
                //         labelText: "Fuel Sensor Tag",
                //         labelStyle: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 20.0,
                //             color: Colors.black)),
                //     hint: Text('Diesel/Petrol'),
                //     validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                //     items: ['Diesel', 'Petrol']
                //         .map((option) => DropdownMenuItem(
                //             value: option, child: Text("$option")))
                //         .toList(),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: FormBuilderTextField(
                //     minLines: 3,
                //     name: "POSONumber",
                //     validators: [
                //       FormBuilderValidators.required(context,),
                //     ],
                //     decoration: InputDecoration(
                //         hintText: "Type Here",
                //         labelText: "PO/SO No",
                //         labelStyle: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 20.0,
                //             color: Colors.black)),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.all(10),
                //   child: FormBuilderTextField(
                //     name: "driverNo",
                //     decoration: InputDecoration(
                //         hintText: "Type Here...",
                //         labelText: "Driver's No.(if Any)",
                //         labelStyle: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 20.0,
                //             color: Colors.black)),
                //   ),
                // ),
                20.verticalSpace,
                TitleAndWidgetShadow(
                  title: 'Remarks',
                  child: FormBuilderTextField(
                    name: "remarks",
                    minLines: 4,
                    decoration: InputDecoration(hintText: "Type here..."),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: !submitButtonLoading
                      ? OutlinedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                            side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                          ),
                          onPressed: () {
                            if (_bOCElogbookFormKey.currentState!.validate()) {
                              _bOCElogbookFormKey.currentState!.save();
                              onSubmit(
                                _bOCElogbookFormKey.currentState!.value,
                              );
                              print(_bOCElogbookFormKey.currentState!.value);
                            } else {
                              setState(() => _autovalidate = true);
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
                ),
              ],
            ),
          )
          // AdditionalDetailForm(),
        ],
      ).paddingFromLTRB(24, 0, 24, 24),
    );
  }
}
