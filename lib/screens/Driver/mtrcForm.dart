import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/components/form_builder_typehead.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as Request;

import '../../components/components.dart';

class MTRCFormScreen extends StatefulWidget {
  final bool mtrcApprovalRequired;
  final bool isVehicleCommander;
  final Function onNext;

  MTRCFormScreen(this.mtrcApprovalRequired, this.isVehicleCommander, this.onNext, {Key? key}) : super(key: key);

  @override
  _MTRCFormScreenState createState() => _MTRCFormScreenState();
}

class _MTRCFormScreenState extends State<MTRCFormScreen> with KeepAliveParentDataMixin {
  var data;
  bool _autoValidate = false;
  final GlobalKey<FormBuilderState> _mtrcApprovalFormKey = GlobalKey<FormBuilderState>();

  final _approvingOfficerTA = SuggestionsBoxController();
  final _vehicleTA = SuggestionsBoxController();

  String? approvingOfficerID;
  String? vehicleID;
  dynamic baseID;
  dynamic subUnitID;
  String? selectedVehicleNumber;
  String? vehicleType = "N/A";
  String? vehicleTypeENUM = "N/A";
  dynamic driverID;
  dynamic currentRole;
  bool itemSet = false;
  List listOfDestinations = [];
  bool canAccessAllVehicles = false;
  var platformQuery = "?platform.id_in=";
  String? nextAVIDate;
  bool initStateFetching = false;

  var request = new Request.Request();

  late ThemeData _themeData;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    var getUserData = json.decode((await request.get(Uri.parse("users/me"))).body);
    var user = getUserData;
    logger.e("getUserData => $getUserData");
    var authString = await getUser();
    var auth = jsonDecode(authString);
    logger.e("authString");
    var roleString = await getCurrentRole();
    var role = roleString;
    logger.e("roleString");
    await fetchLicenseClasses(auth['user']['license_classes']);

    setState(() {
      subUnitID = user['subUnitId'] != null ? user["subUnitId"] : "-1";
      baseID = user['baseAdminId'] != null ? user["baseAdminId"] : "-1";
      driverID = user['id'];
      currentRole = role;
      logger.e("Current role $role}");
      canAccessAllVehicles = user['canAccessAllVehicles'] == null ? false : user['canAccessAllVehicles'];
      logger.e("canAccessAllVehicles ${user['canAccessAllVehicles']}}");
      initStateFetching = true;
    });
  }

  Future fetchLicenseClasses(licenseClasses) async {
    // Fetch platform ids.

    var query = "";
    if (licenseClasses != null) {
      for (var i = 0; i < licenseClasses.length; i++) {
        var cls = licenseClasses[i];
        var id = cls['id'];
        if (i == 0)
          query = query + "?id_in=$id";
        else
          query = query + "&id_in=$id";
      }
    }

    if (query != "") {
      var result = json.decode((await request.get(Uri.parse('license-classes$query'))).body);
      var licenseClasses = result;
      var pQuery = "";
      licenseClasses.forEach((c) {
        var vp = c['vehicles_platforms'];
        vp.forEach((v) {
          pQuery = pQuery + "&platform.id_in=${v['id']}";
        });
      });

      if (pQuery != "")
        setState(() {
          platformQuery = pQuery;
        });
      return "";
    }
  }

  void onToolRemove(index) {
    setState(() {
      listOfDestinations[index] = null;
      listOfDestinations[index + 1] = null;
      listOfDestinations[index + 2] = null;
    });
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

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  Future<List> getApprovingOfficers(pattern) async {
    print("Pattern: $pattern");
    List list = [];
    //[{id: 1188, name: TA}, {id: 1266, name: Demo Transport - Pankaj}]
    try {
      var result1 = json.decode((await request.get(Uri.parse("users/approving-officers?name=$pattern"))).body);
      print("Pattern: $result1");
      list = [...result1];
      if (list.length == 0) {
        setState(() {
          approvingOfficerID = null;
        });
      }
    } catch (e) {
      print("getApprovingOfficers: $e");
      list = [];
    }
    return list;
  }

  // Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    print("Pattern: $pattern");
    List list;
    try {
      print("Can Access: $canAccessAllVehicles");
      String query = 'vehicles?vehicleNumber=$pattern&sub_unit.id=$subUnitID';
      var result = json.decode((await request.get(Uri.parse(query))).body);
      list = result;
      print(result);
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
    List tos = [];
    List requisitionerPurposes = [];

    data.entries.forEach((e) {
      if (e.key.contains("to")) {
        tos.add(e.value);
      } else if (e.key.contains("requisitionerPurpose")) {
        requisitionerPurposes.add(e.value);
      }
    });

    // List of Tools
    List destinations = [];

    for (var i = 0; i < tos.length; i++) {
      if (listOfDestinations[i] != null)
        destinations.add({"to": tos[i], "requisitionerPurpose": requisitionerPurposes[i]});
    }

    final newData = Map.of(data);

    newData.remove("to");
    newData.remove("requisitionerPurpose");

    newData["destinations"] = destinations.toList();
    newData['vehicle'] = vehicleID;
    newData['driver'] = driverID;
    newData['vehicleDropDown'] = vehicleTypeENUM;

    if (currentRole == "PRE_APPROVED_DRIVER") {
      newData['status'] = "Approved";
      newData['approvingOfficer'] = driverID;
    } else {
      newData['approvingOfficer'] = approvingOfficerID;
    }

    widget.onNext(1, newData);
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
    // String query = "vehicle-servicings?vehicle.id=$vehicleId&check_out.checkOutType=AVI&_sort=updated_at:desc&_limit=1";
    // var result = json.decode((await request.get(Uri.parse(query))).body);
    //
    // if (result.length > 0) {
    //   setState(() {
    //     nextAVIDate = result.data[0]['check_out']['type'][0]['nextAVIDate'];
    //   });
    // }
  }

  @override
  void dispose() {
    _approvingOfficerTA.close();
    _vehicleTA.close();
    super.dispose();
  }

  List<Widget> _buildFormChildren() {
    if (currentRole == "PRE_APPROVED_DRIVER") {
      return _widgetPreApprovedDriver();
    } else
      return _widgetsNotPreApprovedDriver();
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
            minLines: 1,
            maxLines: 5,
            key: Key("requisitionerPurpose"),
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            name: "requisitionerPurpose",
            decoration: InputDecoration(
              // hintText: "BOS/AOS/DI/AHS",
              hintText: "Type Here",
            ),
          ),
          // FormBuilderDropdown(
          //   validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
          //   name: "requisitionerPurpose",
          //   hint: Text("BOS/AOS/DI/AHS"),
          //   items: List<DropdownMenuItem>.from(['BOS', 'AOS', 'DI', 'AHS']
          //       .map((s) => DropdownMenuItem(value: s, child: Text(s)))),
          //   icon: const Icon(Icons.expand_more),
          // ),
        ).paddingAll(10));
      });
    }
    setState(() {
      itemSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    setMyItem();
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: initStateFetching
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: <Widget>[
                    Text(
                      'MTRAC Trip Approval Form',
                      style: _themeData.textTheme.headlineSmall!.text244F4E.semiBold,
                    ),
                    10.verticalSpace,
                    Expanded(
                      child: FormBuilder(
                        key: _mtrcApprovalFormKey,
                        autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
                        child: SingleChildScrollView(
                          child: Column(
                            children: _buildFormChildren(),
                          ),
                        ),
                      ),
                    ),
                    15.verticalSpace,
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }

  @override
  bool get wantKeepAlive => true;

  List<Widget> _widgetPreApprovedDriver() {
    var myFormList = [
      TitleAndWidgetShadow(
        title: 'Date',
        child: FormBuilderDateTimePicker(
            name: "tripDate",
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            inputType: InputType.date,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: const Icon(Icons.date_range), // myIcon is a 48px-wide widget.
              ),
            ),
            initialValue: DateTime.now().toUtc(),
            format: new DateFormat('dd MMMM yyyy')
            // readonly: true,
            ),
      ).paddingAll(10),
      TitleAndWidgetShadow(
        title: 'Vehicle Number\n(Press Book Icon to see past 14 eLog)',
        isShadow: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: FormBuilderTypeAhead<dynamic>(
                name: "vehicle",
                textFieldConfiguration: TextFieldConfiguration(),
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
                suggestionsBoxController: _vehicleTA,
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
                    return "${suggestion!['vehicleNumber']}";
                  }
                  return "";
                },
                onSuggestionSelected: (suggestion) => setVehicleNumber(suggestion),
                noItemsFoundBuilder: (context) => Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "No Vehicles Found!",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            10.horizontalSpace,
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Opacity(
                opacity: vehicleID != null ? 1 : 0.2,
                child: InkWell(
                  onTap: () {
                    if (vehicleID != null)
                      Navigator.pushNamed(context, '/driver/past14DaysELog', arguments: int.parse(vehicleID!));
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
          controller: new TextEditingController(
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
      //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
      //             inputType: InputType.date,
      //             initialValue: DateTime.tryParse(nextAVIDate),
      //             decoration: InputDecoration(
      //                 hintText: "DD-MMM-YYYY",
      //                 suffixIcon: Padding(
      //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
      //                   child: const Icon(
      //                       Icons.date_range), // myIcon is a 48px-wide widget.
      //                 )),
      //             format: new DateFormat('dd MMMM yyyy')
      //             // readonly: true,
      //             ),
      //       ).paddingAll(10)
      //     : TitleAndWidgetShadow(
      //         title: 'Vehicle Next AVI Date Due',
      //         child: FormBuilderDateTimePicker(
      //             name: "aviDate",
      //             validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
      //             inputType: InputType.date,
      //             decoration: InputDecoration(
      //                 hintText: "DD-MMM-YYYY",
      //                 suffixIcon: Padding(
      //                   padding: const EdgeInsetsDirectional.only(end: 12.0),
      //                   child: Icon(
      //                       Icons.date_range), // myIcon is a 48px-wide widget.
      //                 )),
      //             format: new DateFormat('dd MMMM yyyy')
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
        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
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
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            if (_mtrcApprovalFormKey.currentState!.saveAndValidate()) {
              onSubmitTripForm(_mtrcApprovalFormKey.currentState!.value);
            } else {
              setState(() => _autoValidate = false);
            }
          },
          child: Text(
            "Next",
            style: TextStyle(color: Colors.black),
          ),
        ),
      )
    ];
    return [...myFormList, ...newList];
  }

  List<Widget> _widgetsNotPreApprovedDriver() {
    var myFormList = [
      TitleAndWidgetShadow(
        title: 'Date',
        child: FormBuilderDateTimePicker(
            name: "tripDate",
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
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
            initialValue: DateTime.now().toUtc(),
            format: new DateFormat('dd MMMM yyyy')
            // readonly: true,
            ),
      ).paddingAll(10),
      TitleAndWidgetShadow(
        title: 'Approval Officer',
        child: FormBuilderTypeAhead<dynamic>(
          name: "approvingOfficer",
          textFieldConfiguration: TextFieldConfiguration(),
          suggestionsBoxController: _approvingOfficerTA,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            (val) {
              if (approvingOfficerID == null) return "Please enter a valid name";
              return null;
            }
          ]),
          decoration: InputDecoration(hintText: 'System Lookup', suffixIcon: const Icon(Icons.expand_more, size: 30)),
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
          onSuggestionSelected: setApprovingOfficer,
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
                textFieldConfiguration: TextFieldConfiguration(),
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
                suggestionsBoxController: _vehicleTA,
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
                    if (vehicleID != null)
                      Navigator.pushNamed(context, '/driver/past14DaysELog', arguments: int.parse(vehicleID!));
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
          controller: new TextEditingController(
            text: "$vehicleTypeENUM ($vehicleType)",
          ),
        ),
      ).paddingAll(10),
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
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
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
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            )),
            side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onPressed: () {
            if (_mtrcApprovalFormKey.currentState!.saveAndValidate()) {
              onSubmitTripForm(_mtrcApprovalFormKey.currentState!.value);
            } else {
              setState(() => _autoValidate = false);
            }
          },
          child: Text(
            "Next",
            style: TextStyle(color: Colors.black),
          ),
        ),
      )
    ];

    return [...myFormList, ...newList];
  }

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  // TODO: implement keptAlive
  bool get keptAlive => true;
}
