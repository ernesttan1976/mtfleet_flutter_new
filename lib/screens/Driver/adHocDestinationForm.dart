import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/components/title_and_widget_shadow.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as Request;

class AdHocDestinationFormScreen extends StatefulWidget {
  final int? tripId;
  final DateTime? tripDate;

  AdHocDestinationFormScreen({Key? key, this.tripId, this.tripDate}) : super(key: key);

  @override
  _AdHocDestinationFormScreenState createState() => _AdHocDestinationFormScreenState();
}

class _AdHocDestinationFormScreenState extends State<AdHocDestinationFormScreen> {
  final GlobalKey<FormBuilderState> _adHocDestinationFormKey = GlobalKey<FormBuilderState>();

  final dioClient = AuthedDio.instance.dio;
  String? approvingOfficerID;
  dynamic subUnitID;
  dynamic driverID;
  bool _autovalidate = false;
  bool submitButtonLoading = false;
  dynamic currentRole;

  var request = new Request.Request();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    var dio = await dioClient;
    var getUserData = await dio.get("/users/me");
    var user = getUserData.data;

    var authString = await getUser();
    var auth = jsonDecode(authString);
    var roleString = await getCurrentRole();
    var role = jsonDecode(roleString);

    setState(() {
      subUnitID = user['sub_unit'] != null ? user["sub_unit"] : "-1";
      driverID = auth['user']['id'];
      currentRole = role['name'];
    });
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  Future<List> getApprovingOfficers(pattern) async {
    print("Pattern: $pattern");
    List list;
    try {
      var result1 = json.decode((await request.get(Uri.parse("users/approving-officers?name=$pattern"))).body);
      list = [...result1];
      if (list.length == 0) {
        setState(() {
          approvingOfficerID = null;
        });
      }
    } catch (e) {
      list = [];
    }
    return list;
  }

  void setApprovingOfficer(officer) {
    print("$officer");
    setState(() {
      approvingOfficerID = "${officer['id']}";
    });
  }

  void onSubmit(var data, var context) async {
    try {
      setState(() {
        submitButtonLoading = true;
      });
      data['tripId'] = widget.tripId;

      final _dio = await dioClient;
      final _res = await _dio.post('/trips/adHoc-destination', data: data);
      if (_res.statusCode == 201) {
        showAlertDialog(context, 'Success', _res.statusMessage);
      }
      setState(() {
        submitButtonLoading = false;
      });
    } catch (e) {
      setState(() {
        submitButtonLoading = false;
      });
      showAlertDialog(context, 'Error', e as String, isPop: false);
    }
  }

  // List<Widget> _buildChildren() {
  //   if (currentRole == "Pre-Approved Driver") {
  //     var formList = [
  //       Row(
  //         children: <Widget>[
  //           Container(
  //             padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  //             child: Text('Trip Date',
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .bodyText1
  //                     .copyWith(fontWeight: FontWeight.bold)),
  //           ),
  //         ],
  //       ),
  //       Row(
  //         children: <Widget>[
  //           Container(
  //             padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  //             child: Text("${widget.tripDate}",
  //                 style: Theme.of(context).textTheme.bodyText1),
  //           ),
  //         ],
  //       ),
  //       FormBuilder(
  //         key: _adHocDestinationFormKey,
  //         autovalidate: _autovalidate,
  //         child: Column(
  //           children: <Widget>[
  //             Padding(
  //               padding: EdgeInsets.all(10),
  //               child: FormBuilderTextField(
  //                 validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
  //                 name: "to",
  //                 decoration: InputDecoration(
  //                     labelText: "Ad-Hoc Destination",
  //                     hintText: "Type Here",
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20.0,
  //                         color: Colors.black)),
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.all(10),
  //               child: FormBuilderTextField(
  //                 minLines: 3,
  //                 validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
  //                 name: "requisitionerPurpose",
  //                 decoration: InputDecoration(
  //                     hintText: "Type Here",
  //                     labelText: "Requisitioner's Purpose",
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20.0,
  //                         color: Colors.black)),
  //               ),
  //             ),
  //             Container(
  //               width: MediaQuery.of(context).size.width * 0.9,
  //               padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
  //               child: !submitButtonLoading
  //                   ? OutlineButton(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30.0),
  //                       ),
  //                       onPressed: () {
  //                         if (_adHocDestinationFormKey.currentState
  //                             .validate()) {
  //                           _adHocDestinationFormKey.currentState.save();
  //                           onSubmit(
  //                               _adHocDestinationFormKey.currentState.value,
  //                               context);
  //                         } else {
  //                           setState(() => _autovalidate = true);
  //                         }
  //                       },
  //                       borderSide:
  //                           BorderSide(color: Theme.of(context).primaryColor),
  //                       child: Text(
  //                         "Submit",
  //                         style: TextStyle(color: Colors.black),
  //                       ),
  //                     )
  //                   : Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //             ),
  //           ],
  //         ),
  //       )
  //     ];
  //     return formList;
  //   } else if (currentRole != null) {
  //     var formList = [
  //       Row(
  //         children: <Widget>[
  //           Container(
  //             padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  //             child: Text('Trip Date',
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .bodyText1
  //                     .copyWith(fontWeight: FontWeight.bold)),
  //           ),
  //         ],
  //       ),
  //       Row(
  //         children: <Widget>[
  //           Container(
  //             padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
  //             child: Text("${widget.tripDate}",
  //                 style: Theme.of(context).textTheme.bodyText1),
  //           ),
  //         ],
  //       ),
  //       FormBuilder(
  //         key: _adHocDestinationFormKey,
  //         autovalidate: _autovalidate,
  //         child: Column(
  //           children: <Widget>[
  //             Padding(
  //               padding: EdgeInsets.all(10),
  //               child: FormBuilderTypeAhead(
  //                 name: "approvingOfficer",
  //                 suggestionsBoxController: _approvingOfficerTA,
  //                 validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
  //                 decoration: InputDecoration(
  //                     labelText: "Approving Officer",
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20.0,
  //                         color: Colors.black)),
  //                 itemBuilder: (context, itemData) {
  //                   return itemData != null || itemData.length != 0
  //                       ? ListTile(title: Text("${itemData['name']}"))
  //                       : [];
  //                 },
  //                 suggestionsCallback: (pattern) async {
  //                   return await getApprovingOfficers(pattern);
  //                 },
  //                 selectionToTextTransformer: (suggestion) {
  //                   if (suggestion != "") {
  //                     return "${suggestion['name']}";
  //                   }
  //                   return "";
  //                 },
  //                 onSuggestionSelected: (suggestion) =>
  //                     setApprovingOfficer(suggestion),
  //                 noItemsFoundBuilder: (context) => Padding(
  //                   padding: EdgeInsets.all(10),
  //                   child: Text(
  //                     "No Approving Officers Found!",
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.all(10),
  //               child: FormBuilderTextField(
  //                 validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
  //                 name: "to",
  //                 decoration: InputDecoration(
  //                     labelText: "Ad-Hoc Destination",
  //                     hintText: "Type Here",
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20.0,
  //                         color: Colors.black)),
  //               ),
  //             ),
  //             Padding(
  //               padding: EdgeInsets.all(10),
  //               child: FormBuilderTextField(
  //                 minLines: 3,
  //                 validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
  //                 name: "requisitionerPurpose",
  //                 decoration: InputDecoration(
  //                     hintText: "Type Here",
  //                     labelText: "Requisitioner's Purpose",
  //                     labelStyle: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20.0,
  //                         color: Colors.black)),
  //               ),
  //             ),
  //             Container(
  //               width: MediaQuery.of(context).size.width * 0.9,
  //               padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
  //               child: !submitButtonLoading
  //                   ? OutlineButton(
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30.0),
  //                       ),
  //                       onPressed: () {
  //                         if (_adHocDestinationFormKey.currentState
  //                             .validate()) {
  //                           _adHocDestinationFormKey.currentState.save();
  //                           onSubmit(
  //                               _adHocDestinationFormKey.currentState.value,
  //                               context);
  //                         } else {
  //                           setState(() => _autovalidate = true);
  //                         }
  //                       },
  //                       borderSide:
  //                           BorderSide(color: Theme.of(context).primaryColor),
  //                       child: Text(
  //                         "Submit",
  //                         style: TextStyle(color: Colors.black),
  //                       ),
  //                     )
  //                   : Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //             ),
  //           ],
  //         ),
  //       )
  //     ];
  //     return formList;
  //   } else {
  //     return [
  //       Center(
  //         child: CircularProgressIndicator(),
  //       )
  //     ];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Ad-Hoc Destination Form',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          // elevation: 5,
        ),
        body: Stack(
          children: <Widget>[
            FormBuilder(
              key: _adHocDestinationFormKey,
              autovalidateMode: _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TitleAndWidgetShadow(
                      title: 'Ad-Hoc Destination',
                      child: FormBuilderTextField(
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        name: "to",
                        decoration: InputDecoration(
                          hintText: "Type Here",
                        ),
                      ),
                    ).paddingAll(10),
                    TitleAndWidgetShadow(
                      title: "Requisitioner's Purpose",
                      child: FormBuilderTextField(
                        minLines: 3,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        name: "requisitionerPurpose",
                        decoration: InputDecoration(
                          hintText: "Type Here",
                        ),
                      ),
                    ).paddingAll(10),
                    TitleAndWidgetShadow(
                      title: "Details",
                      child: FormBuilderTextField(
                        minLines: 3,
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        name: "details",
                        decoration: InputDecoration(
                          hintText: "Type Here",
                        ),
                      ),
                    ).paddingAll(10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.only(top: 30),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () {
                          if (_adHocDestinationFormKey.currentState!.validate()) {
                            _adHocDestinationFormKey.currentState!.save();
                            onSubmit(_adHocDestinationFormKey.currentState!.value, context);
                          } else {
                            setState(() => _autovalidate = true);
                          }
                        },
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    30.verticalSpace,
                  ],
                ),
              ),
            ).paddingHorizontal(15),
            if (submitButtonLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ));
  }
}
