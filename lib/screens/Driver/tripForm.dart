// Create a Form widget.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/components/form_builder_typehead.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request_api;

class TripFormScreen extends StatefulWidget {
  final bool mtrcApprovalRequired;
  final bool isVehicleCommander;

  const TripFormScreen(this.mtrcApprovalRequired, this.isVehicleCommander, {Key? key}) : super(key: key);

  @override
  TripFormScreenState createState() => TripFormScreenState();
}

class TripFormScreenState extends State<TripFormScreen> {
  final GlobalKey<FormBuilderState> _tripFormKey = GlobalKey<FormBuilderState>();

  final SuggestionsController _approvingOfficerTA = SuggestionsController();
  final SuggestionsController _vehicleTA = SuggestionsController();

  final dioClient = AuthedDio.instance.dio;

  String? approvingOfficerID;
  String? vehicleID;
  dynamic subUnitID;
  dynamic baseID;
  String? selectedVehicleNumber;
  String? vehicleType = "N/A";
  String? vehicleTypeENUM = "N/A";
  dynamic driverID;
  dynamic currentRole;
  bool submitButtonLoading = false;
  bool itemSet = false;
  bool initStateFetching = false;
  List listOfDestinations = [];
  var platformQuery = "?platform.id_in=";
  final logger = Logger();
  var request = request_api.Request();

  String? nextAVIDate;

  void loadUser() async {
    if (!initStateFetching) {
      var user = json.decode((await request.get(Uri.parse("users/me"))).body);
      var auth = jsonDecode(await getUser());
      var roleString = await getCurrentRole();

      logger.e("initStateFetching ${user['canAccessAllVehicles']}");

      await fetchLicenseClasses(auth['user']['license_classes']);
      setState(() {
        subUnitID = user['subUnitId'] != null ? user["subUnitId"] : "-1";
        baseID = user['baseAdminId'] != null ? user["baseAdminId"] : "-1";
        driverID = user['id'];
        currentRole = roleString;
        initStateFetching = true;
      });
    }
  }

  Future fetchLicenseClasses(licenseClasses) async {
    // Fetch platform ids.

    var query = "";
    if (licenseClasses != null) {
      for (var i = 0; i < licenseClasses.length; i++) {
        var cls = licenseClasses[i];
        var id = cls['id'];
        if (i == 0) {
          query = "?id_in=$id";
        } else {
          query = "$query&id_in=$id";
        }
      }
    }

    if (query != "") {
      var dio = await dioClient;
      var result = await dio.get("/license-classes$query");
      var licenseClasses = result.data;
      var pQuery = "";
      for (var c in licenseClasses) {
        var vp = c['vehicles_platforms'];
        for (var v in vp) {
          pQuery = "$pQuery&platform.id_in=${v['id']}";
        }
      }

      print("Got DATA: $pQuery");

      if (pQuery.isNotEmpty) {
        setState(() {
          platformQuery = pQuery;
        });
      }
      return "";
    }
  }

  // Add New Destination fields in list
  void addNewDestination() {
    print("The Length of List is ${listOfDestinations.length}");
    int index = listOfDestinations.length;
    setState(() {
      listOfDestinations.addAll([
        Padding(
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => onToolRemove(index),
            )),
        TitleAndWidgetShadow(
          title: 'To',
          child: FormBuilderTextField(
            key: Key("$index"),
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            name: "to$index",
            decoration: InputDecoration(
              hintText: "Paya Lebar Camp",
            ),
          ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: "Requisitioner's Purpose",
          child:
              // FormBuilderDropdown(
              //   key: Key("$index"),
              //   validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
              //   name: "requisitionerPurpose$index",
              //   hint: Text("BOS/AOS/DI/AHS"),
              //   items: List<DropdownMenuItem>.from(['BOS', 'AOS', 'DI', 'AHS']
              //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))),
              // ),
              FormBuilderTextField(
            minLines: 1,
            maxLines: 5,
            key: Key("$index"),
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            name: "requisitionerPurpose$index",
            decoration: InputDecoration(
              // hintText: "BOS/AOS/DI/AHS",
              hintText: "Type Here",
            ),
          ),
        ).paddingAll(10)
      ]);
    });
  }

  void onToolRemove(index) {
    setState(() {
      listOfDestinations[index] = null;
      listOfDestinations[index + 1] = null;
      listOfDestinations[index + 2] = null;
    });
  }

  // To Encode the date into JSON
  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  // Get List of approving officer from server
  Future<List> getApprovingOfficers(pattern) async {
    print("Pattern: $pattern");
    List list;
    try {
      var result1 = json.decode((await request.get(Uri.parse("users/approving-officers?name=$pattern"))).body);
      list = [...result1];
      if (list.isEmpty) {
        setState(() {
          approvingOfficerID = null;
        });
      }
    } catch (e) {
      list = [];
    }
    return list;
  }

  // Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    print("Pattern: $pattern");
    List list;
    try {
      String query = 'vehicles?vehicleNumber=$pattern&sub_unit.id=$subUnitID';
      var result = json.decode((await request.get(Uri.parse(query))).body);
      list = result;
      setState(() {
        vehicleID = null;
        vehicleType = null;
        vehicleTypeENUM = null;
      });
    } catch (e) {
      list = [];
    }
    return list;
  }

  // Form Submit
  void onSubmitTripForm(Map<String, dynamic> data) async {
    try {
      setState(() {
        submitButtonLoading = true;
      });

      final List<dynamic> tos = [];
      final List<dynamic> requisitionerPurposes = [];
      print('1');
      for (final e in data.entries) {
        if (e.key.contains("to")) {
          tos.add(e.value);
        } else if (e.key.contains("requisitionerPurpose")) {
          requisitionerPurposes.add(e.value);
        }
      }

      // List of Tools
      List destinations = [];

      for (var i = 0; i < tos.length; i++) {
        if (listOfDestinations[i] != null) {
          destinations.add({"to": tos[i], "requisitionerPurpose": requisitionerPurposes[i]});
        }
      }

      // data.addAll({'vehicle': vehicleID, 'driver': driverID});
      // print('2');
      // if (currentRole == "PRE_APPROVED_DRIVER") {
      //   data['status'] = "Approved";
      //   data['approvingOfficer'] = int.parse(driverID.toString());
      // } else {
      //   data['approvingOfficer'] = int.parse(approvingOfficerID);
      // }
      final Map<String, dynamic> payload = {
        "tripDate": data['tripDate'].toUtc().toIso8601String(),
        "endedAt": DateTime.now().toUtc().toIso8601String(),
        //"aviDate": data['aviDate'].toUtc().toIso8601String(),
        "vehicle": int.parse(vehicleID!),
        "currentMeterReading": 22,
        "isTripFromPreApprovedDriver": currentRole != 'DRIVER',
        "approvingOfficer":
            currentRole == "PRE_APPROVED_DRIVER" ? int.parse(driverID.toString()) : int.parse(approvingOfficerID!),
        "destinations": destinations.toList(),
        // "MTRACForm": {
        //   "overAllRisk": "string",
        //   "dispatchDate": "2021-11-18T16:26:32.928Z",
        //   "dispatchTime": "2021-11-18T16:26:32.928Z",
        //   "releaseDate": "2021-11-18T16:26:32.928Z",
        //   "releaseTime": "2021-11-18T16:26:32.928Z",
        //   "isAdditionalDetailApplicable": true,
        //   "safetyMeasures": "string",
        //   "rankAndName": "string",
        //   "personalPin": "string",
        //   "filledBy": "FrontPassenger",
        //   "otherRiskAssessmentChecklist": [
        //     "string"
        //   ],
        //   "driverRiskAssessmentChecklist": [
        //     "string"
        //   ],
        //   "quizzes": [
        //     {
        //       "question": "string",
        //       "answer": "string"
        //     }
        //   ]
        // }
      };
      var dataJSON = jsonEncode(payload, toEncodable: myEncode);
      print(dataJSON);
      final dio = await dioClient;
      var response = await dio.post("/trips", data: dataJSON);

      print(response.data);
      setState(() {
        submitButtonLoading = false;
      });
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", "Trip approval form is sent successfully!");
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

  void setApprovingOfficer(officer) {
    print("$officer");
    setState(() {
      approvingOfficerID = "${officer['id']}";
    });
  }

  void setVehicleNumber(vehicle) {
    print("$vehicle");
    setState(() {
      vehicleID = "${vehicle['id']}";
      vehicleType = "${vehicle['vehicleType']}";
      selectedVehicleNumber = "${vehicle['vehicleNumber']}";
      vehicleTypeENUM = "${vehicle['model']}";
    });
    setAVIDate(vehicle['id']);
  }

  void setAVIDate(int vehicleId) async {
    String query =
        "/vehicle-servicings?vehicle.id=$vehicleId&check_out.checkOutType=AVI&_sort=updated_at:desc&_limit=1";
    var result = json.decode((await request.get(Uri.parse(query))).body);

    if (result.length > 0) {
      setState(() {
        nextAVIDate = result.data[0]['check_out']['type'][0]['nextAVIDate'];
      });
    }
  }

  void _onChanged(dynamic val) => print(val);

  // Submission Form Alert

  void submissionFormAlert(var tripFormData) {
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
          content: Text(
            currentRole == "PRE_APPROVED_DRIVER"
                ? "Are you sure to send the trip form?"
                : "The trip approval will now be submitted to the Approving Officer Proceed?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              width: MediaQuery.of(context).size.width * 1.0,
              height: 50,
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSubmitTripForm(tripFormData);
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _approvingOfficerTA.dispose();
    _vehicleTA.dispose();
    super.dispose();
  }

  List<Widget> _buildFormChildren() {
    if (currentRole == "PRE_APPROVED_DRIVER") {
      var myFormList = [
        TitleAndWidgetShadow(
          title: 'Date',
          child: FormBuilderDateTimePicker(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "tripDate",
              onChanged: _onChanged,
              inputType: InputType.date,
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: const Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                ),
              ),
              // initialDate: ,
              // validator: (val) => null,
              // initialTime: TimeOfDay(hour: 8, minute: 0),
              initialValue: DateTime.now(),
              format: DateFormat('dd MMMM yyyy')
              // readonly: true,
              ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: 'Vehicle Number\n(Press Book Icon to see past 14 eLog)',
          isShadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: FormBuilderTypeAhead<dynamic>(
                  name: "vehicle",
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    (val) {
                      if (vehicleType == null) {
                        return "Please enter a valid vehicle number";
                      } else if (vehicleID == null) {
                        return "Please select a valid vehicle";
                      }
                      return null;
                    }
                  ]),
                  suggestionsController: _vehicleTA,
                  decoration:
                      InputDecoration(hintText: 'System Lookup', suffixIcon: const Icon(Icons.expand_more, size: 30)),
                  itemBuilder: (context, itemData) {
                    return itemData != null || itemData.length != 0
                        ? ListTile(title: Text("${itemData['vehicleNumber']}"))
                        : Container();
                  },
                  suggestionsCallback: (pattern) async {
                    return await getVehicles(pattern);
                  },
                  selectionToTextTransformer: (suggestion) {
                    if (suggestion != "") {
                      return "${suggestion['vehicleNumber']}";
                    }
                    return "";
                  },
                  onSuggestionSelected: setVehicleNumber,
                  noItemsFoundBuilder: (context) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No Vehicles Found!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).shadow(),
              ),
              10.horizontalSpace,
              Padding(
                padding: const EdgeInsets.only(top: 11),
                child: Opacity(
                  opacity: vehicleID != null ? 1 : 0.2,
                  child: InkWell(
                    onTap: () {
                      if (vehicleID != null) {
                        Navigator.pushNamed(context, '/driver/past14DaysELog', arguments: int.parse(vehicleID!));
                      }
                    },
                    child: Image.asset('ic_book'.assetPathIcon, width: 25),
                  ),
                ),
              ),
            ],
          ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: 'Vehicle / Motorcycle',
          child: TextFormField(
            enabled: false,
            controller: TextEditingController(
              text: "$vehicleTypeENUM ($vehicleType)",
            ),
          ),
        ).paddingAll(10),
        // nextAVIDate != null
        //     ? TitleAndWidgetShadow(
        //         title: 'Vehicle Next AVI Date Due',
        //         child: FormBuilderDateTimePicker(
        //             key: Key("nextAviDateKey"),
        //             name: "aviDate",
        //             onChanged: _onChanged,
        //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
        //             inputType: InputType.date,
        //             initialValue: DateTime.tryParse(nextAVIDate),
        //             decoration: InputDecoration(
        //                 hintText: "DD-MMM-YYYY",
        //                 suffixIcon: Padding(
        //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
        //                   child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
        //                 )),
        //             format: DateFormat('dd MMMM yyyy')
        //             // readonly: true,
        //             ),
        //       ).paddingAll(10)
        //     : TitleAndWidgetShadow(
        //         title: 'Vehicle Next AVI Date Due',
        //         child: FormBuilderDateTimePicker(
        //             name: "aviDate",
        //             onChanged: _onChanged,
        //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
        //             inputType: InputType.date,
        //             decoration: InputDecoration(
        //                 hintText: "DD-MMM-YYYY",
        //                 suffixIcon: Padding(
        //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
        //                   child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
        //                 )),
        //             format: DateFormat('dd MMMM yyyy')
        //             // readonly: true,
        //             ),
        //       ).paddingAll(10)
      ];

      for (var item in listOfDestinations) {
        if (item != null) {
          myFormList.add(item);
        }
      }

      var newList = [
        Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.only(top: 20),
            child: OutlinedButton(
              style: ButtonStyle(
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                ),
                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
              ),
              onPressed: () {
                addNewDestination();
              },
              child: Text(
                "Add Another Destination",
                style: TextStyle(color: Colors.black),
              ),
            )),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.only(top: 20),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
            ),
            onPressed: () {
              // Navigator.pushNamed(
              //     context, "/driver/quiz");
              if (_tripFormKey.currentState?.saveAndValidate() ?? false) {
                submissionFormAlert(_tripFormKey.currentState!.value);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        30.verticalSpace,
      ];

      return [...myFormList, ...newList];
    } else {
      logger.e("Else if called");
      var myFormList = [
        TitleAndWidgetShadow(
          title: 'Date',
          child: FormBuilderDateTimePicker(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "tripDate",
              onChanged: _onChanged,
              inputType: InputType.date,
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: const Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                ),
              ),
              initialValue: DateTime.now(),
              format: DateFormat('dd MMMM yyyy')
              // readonly: true,
              ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: 'Approving Officer',
          child: FormBuilderTypeAhead<dynamic>(
            name: "approvingOfficer",
            decoration: InputDecoration(hintText: 'System Lookup', suffixIcon: const Icon(Icons.expand_more, size: 30)),
            suggestionsController: _approvingOfficerTA,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              (val) {
                if (approvingOfficerID == null) return "Please enter a valid name";
                return null;
              }
            ]),
            itemBuilder: (context, itemData) {
              return itemData != null || itemData.length != 0
                  ? ListTile(title: Text("${itemData['name']}"))
                  : Container();
            },
            suggestionsCallback: (pattern) async {
              return await getApprovingOfficers(pattern);
            },
            selectionToTextTransformer: (suggestion) {
              if (suggestion != "") {
                return "${suggestion['name']}";
              }
              return "";
            },
            onSuggestionSelected: (suggestion) => setApprovingOfficer(suggestion),
            noItemsFoundBuilder: (context) => Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "No Approving Officers Found!",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: 'Vehicle Number\n(Press Book Icon to see past 14 eLog)',
          isShadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: FormBuilderTypeAhead<dynamic>(
                  name: "vehicle",
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    (val) {
                      if (vehicleType == null) {
                        return "Please enter a valid vehicle number";
                      } else if (vehicleID == null) {
                        return "Please select a valid vehicle";
                      }
                      return null;
                    }
                  ]),
                  suggestionsController: _vehicleTA,
                  decoration:
                      InputDecoration(hintText: 'System Lookup', suffixIcon: const Icon(Icons.expand_more, size: 30)),
                  itemBuilder: (context, itemData) {
                    return itemData != null || itemData.length != 0
                        ? ListTile(title: Text("${itemData['vehicleNumber']}"))
                        : Container();
                  },
                  suggestionsCallback: (pattern) async {
                    return await getVehicles(pattern);
                  },
                  selectionToTextTransformer: (suggestion) {
                    if (suggestion != "") {
                      return "${suggestion['vehicleNumber']}";
                    }
                    return "";
                  },
                  onSuggestionSelected: setVehicleNumber,
                  noItemsFoundBuilder: (context) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No Vehicles Found!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).shadow(),
              ),
              10.horizontalSpace,
              Padding(
                padding: const EdgeInsets.only(top: 11),
                child: Opacity(
                  opacity: vehicleID != null ? 1 : 0.2,
                  child: InkWell(
                    onTap: () {
                      if (vehicleID != null) {
                        Navigator.pushNamed(context, '/driver/past14DaysELog', arguments: int.parse(vehicleID!));
                      }
                    },
                    child: Image.asset('ic_book'.assetPathIcon, width: 25),
                  ),
                ),
              ),
            ],
          ),
        ).paddingAll(10),
        TitleAndWidgetShadow(
          title: 'Vehicle / Motorcycle',
          child: TextFormField(
            enabled: false,
            controller: TextEditingController(
              text: "$vehicleTypeENUM ($vehicleType)",
            ),
          ),
        ).paddingAll(10),
        // nextAVIDate != null
        //     ? TitleAndWidgetShadow(
        //         title: 'Vehicle Next AVI Date Due',
        //         child: FormBuilderDateTimePicker(
        //             key: Key("nextAviDateKey"),
        //             name: "aviDate",
        //             onChanged: _onChanged,
        //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
        //             inputType: InputType.date,
        //             initialValue: DateTime.tryParse(nextAVIDate),
        //             decoration: InputDecoration(
        //                 hintText: "DD-MMM-YYYY",
        //                 suffixIcon: Padding(
        //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
        //                   child: Icon(Icons
        //                       .date_range), // myIcon is a 48px-wide widget.
        //                 )),
        //             format: DateFormat('dd MMMM yyyy')
        //             // readonly: true,
        //             ),
        //       ).paddingAll(10)
        //     : TitleAndWidgetShadow(
        //         title: 'Vehicle Next AVI Date Due',
        //         child: FormBuilderDateTimePicker(
        //             name: "aviDate",
        //             onChanged: _onChanged,
        //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
        //             inputType: InputType.date,
        //             decoration: InputDecoration(
        //                 hintText: "DD-MMM-YYYY",
        //                 suffixIcon: Padding(
        //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
        //                   child: Icon(Icons
        //                       .date_range), // myIcon is a 48px-wide widget.
        //                 )),
        //             format: DateFormat('dd MMMM yyyy')),
        //       ).paddingAll(10),
      ];

      for (var item in listOfDestinations) {
        if (item != null) {
          myFormList.add(item);
        }
      }

      var newList = [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
            ),
            onPressed: () {
              addNewDestination();
            },
            child: Text(
              "Add Another Destination",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: OutlinedButton(
            style: ButtonStyle(
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor)),
            ),
            onPressed: () {
              // Navigator.pushNamed(
              //     context, "/driver/quiz");
              if (_tripFormKey.currentState?.saveAndValidate() ?? false) {
                submissionFormAlert(_tripFormKey.currentState!.value);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        30.verticalSpace,
      ];

      return [...myFormList, ...newList];
    }
  }

  void setMyItem() {
    if (!itemSet) {
      setState(() {
        listOfDestinations.add(
          TitleAndWidgetShadow(
            title: 'To',
            child: FormBuilderTextField(
              name: "to",
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              decoration: InputDecoration(
                hintText: "Paya Lebar Camp",
              ),
            ),
          ).paddingAll(10),
        );
        listOfDestinations.add(TitleAndWidgetShadow(
          title: "Requisitioner's Purpose",
          child: FormBuilderTextField(
            minLines: 3,
            maxLines: 3,
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            name: "requisitionerPurpose",
            decoration: InputDecoration(
              hintText: "Type Here",
            ),
          ),
        ).paddingAll(10));
      });
    }
    setState(() {
      itemSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    setMyItem();
    logger.e("Build Called");
    if (mounted) loadUser();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip Approval Form',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // elevation: 5,
      ),
      body: Stack(
        children: <Widget>[
          FormBuilder(
            key: _tripFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: _buildFormChildren(),
              ),
            ),
          ).paddingHorizontal(15),
          if (submitButtonLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
