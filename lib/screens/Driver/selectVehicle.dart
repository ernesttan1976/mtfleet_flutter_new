// Create a Form widget.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/components/form_builder_typehead.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/util/currentUserData.dart';

import '../../components/AlertDialog.dart';

class SelectVehicleFormScreen extends StatefulWidget {
  final Function? onSubmitForm;

  SelectVehicleFormScreen({this.onSubmitForm, Key? key}) : super(key: key);

  @override
  _SelectVehicleFormScreenState createState() => _SelectVehicleFormScreenState();
}

class _SelectVehicleFormScreenState extends State<SelectVehicleFormScreen> {
  final GlobalKey<FormBuilderState> _selectVehicleFormKey = GlobalKey<FormBuilderState>();

  final _vehicleTA = SuggestionsBoxController();

  final dioClient = AuthedDio.instance.dio;

  final _showFuelReceive = BehaviorSubject<bool>();

  DateTime? _timeArrived, _timeStarted;

  String? approvingOfficerID;
  String? vehicleID;
  dynamic subUnitID;
  String? selectedVehicleNumber;
  String? vehicleType = "N/A";
  String? vehicleTypeENUM = "N/A";
  dynamic driverID;
  dynamic baseID;
  dynamic currentRole;
  bool submitButtonLoading = false;
  bool canAccessAllVehicles = false;
  bool itemSet = false;
  bool initStateFetching = false;
  List listOfDestinations = [];
  var platformQuery = "&platform.id_in=";

  String? nextAVIDate;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    _showFuelReceive.close();
    _vehicleTA.close();
    super.dispose();
  }

  void loadUser() async {
    try {
      var dio = await dioClient;
      var getUserData = await dio.get("/users/me");
      var user = getUserData.data;

      var authString = await getUser();
      var auth = jsonDecode(authString);

      var roleString = await getCurrentRole();
      var role = roleString;

      await fetchLicenseClasses(auth['user']['license_classes']);

      setState(() {
        subUnitID = user['sub_unit'] != null ? user["sub_unit"] : "-1";
        baseID = user['base'] != null ? user["base"] : "-1";
        driverID = user['id'];
        currentRole = role;
        canAccessAllVehicles = user['canAccessAllVehicles'] == null ? false : user['canAccessAllVehicles'];
        initStateFetching = true;
      });
    } catch (e) {
      initStateFetching = true;
      showAlertDialog(context, 'Error', e.toString());
    }
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
      var dio = await dioClient;
      var result = await dio.get("/license-classes$query");
      var licenseClasses = result.data;
      var pQuery = "";
      licenseClasses.forEach((c) {
        var vp = c['vehicles_platforms'];
        vp.forEach((v) {
          pQuery = pQuery + "&platform.id_in=${v['id']}";
        });
      });

      print("Got DATA: $pQuery");

      if (pQuery != "")
        setState(() {
          platformQuery = pQuery;
        });
      return "";
    }
  }

  // To Encode the date into JSON
  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  // Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    print("Pattern: $pattern");

    List list;
    try {
      var dio = await dioClient;
      print("Can Access: $canAccessAllVehicles");

      String query = canAccessAllVehicles == null || !canAccessAllVehicles
          ? "/vehicles?_limit=5&sub_unit.id=$subUnitID&vehicleNumber=$pattern$platformQuery"
          : "/vehicles?_limit=5&sub_unit.base=$baseID&vehicleNumber=$pattern$platformQuery";
      var result = await dio.get(query);
      // print("query: $query");
      list = result.data;
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

  void setVehicleNumber(vehicle) {
    print("Vehicle : $vehicle");
    setState(() {
      vehicleID = "${vehicle['id']}";
      vehicleType = "${vehicle['vehicleType']}";
      selectedVehicleNumber = "${vehicle['vehicleNumber']}";
    });
  }

  var logger = Logger();

  void _submit(var formData) async {
    try {
      setState(() {
        submitButtonLoading = true;
      });
      final _eLogData = {};
      _eLogData.addAll({
        'startTime': _timeStarted?.toUtc().toIso8601String(),
        'endTime': _timeArrived?.toUtc().toIso8601String(),
        "requisitionerPurpose": formData['requisitionerPurpose'],
        "remarks": formData['remarks'],

        ///TODO: đang fake data
        "stationaryRunningTime": 2,
        "totalDistance": 2,
        "POSONumber": 2,
      });
      if (_showFuelReceive.value) {
        _eLogData.addAll({
          "fuelReceived": double.parse(formData['fuelReceived']),
          "fuelType": formData['fuelType'],
        });
      }

      var data = {
        "tripDate": formData['tripDate'].toUtc().toIso8601String(),
        "vehicleId": int.parse(vehicleID!),
        "requisitionerPurpose": formData['requisitionerPurpose'],
        "currentMeterReading": double.parse(formData['intialmeterReading']),
        "eLog": _eLogData,
      };
      var dataJSON = jsonEncode(data, toEncodable: myEncode);
      logger.e(dataJSON);
      var dio = await dioClient;
      var response = await dio.post("/bos-aos-pol", data: dataJSON);

      setState(() {
        submitButtonLoading = false;
      });
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", response.statusMessage);
      } else if (response.statusCode! >= 400 || response.statusCode! < 500) {
        logger.e("Response is 400");
      } else if (response.statusCode! >= 500) {
        logger.e("Response is 500");
      } else {
        showAlertDialog(context, "Failure", response.statusMessage, isPop: false);
      }
    } on DioError catch (e) {
      if (e.response!.statusCode! >= 400 || e.response!.statusCode! < 500) {
        logger.e("Response is 400 ${e.response!.data!}");
      }
      setState(() {
        submitButtonLoading = false;
      });
      showAlertDialog(context, "Error", e.response!.data!["message"], isPop: false);
    }
  }

  ValueChanged _onChanged = (val) => print(val);

  // Submission Form Alert

  List<Widget> _buildFormChildren() {
    var myFormList = [
      TitleAndWidgetShadow(
        title: 'Date',
        child: FormBuilderDateTimePicker(
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            name: "tripDate",
            onChanged: _onChanged,
            inputType: InputType.date,
            decoration: InputDecoration(suffixIcon: const Icon(Icons.date_range, size: 25)),
            // initialDate: ,
            // validator: (val) => null,
            // initialTime: TimeOfDay(hour: 8, minute: 0),
            initialValue: DateTime.now(),
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
                suggestionsBoxController: _vehicleTA,
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
                onSuggestionSelected: (suggestion) => setVehicleNumber(suggestion),
                noItemsFoundBuilder: (context) => Text(
                  "No Vehicles Found!",
                  textAlign: TextAlign.center,
                ).paddingAll(10),
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
        title: 'Requisitioner Purpose',
        child: FormBuilderDropdown(
          name: "requisitionerPurpose",
          hint: Text('BOS/AOS/POL/DI/AHS'),
          onChanged: (val) {
            if (val == 'POL') {
              _showFuelReceive.add(true);
            } else
              _showFuelReceive.add(false);
          },
          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
          items: ['BOS', 'AOS', 'POL', 'DI', 'AHS']
              .map((option) => DropdownMenuItem(value: option, child: Text("$option")))
              .toList(),
          icon: const Icon(Icons.expand_more, size: 25),
        ),
      ).paddingAll(10),
      TitleAndWidgetShadow(
        title: 'Time Started',
        child: FormBuilderDateTimePicker(
            name: "timeStarted",
            onChanged: (val) {
              _timeStarted = DateTime.now().copyWith(hourN: val?.hour, p: val?.minute);
              _onChanged(_timeStarted);
            },
            inputType: InputType.time,
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            decoration: InputDecoration(
                hintText: "HH-MM",
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: const Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                )),
            format: new DateFormat('HH:mm')
            // readonly: true,
            ),
      ).paddingAll(10),
      TitleAndWidgetShadow(
        title: 'Time End',
        child: FormBuilderDateTimePicker(
            name: "timeArrived",
            onChanged: (val) {
              _timeArrived = DateTime.now().copyWith(hourN: val!.hour, p: val.minute);
              _onChanged(_timeArrived);
            },
            inputType: InputType.time,
            validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
            decoration: InputDecoration(
                hintText: "HH-MM",
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: const Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                )),
            format: new DateFormat('HH:mm')
            // readonly: true,
            ),
      ).paddingAll(10),
      TitleAndWidgetShadow(
        title: 'Current Meter Reading',
        child: FormBuilderTextField(
          name: "intialmeterReading",
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.numeric(errorText: "Must be numeric!"),
            FormBuilderValidators.min(0)
          ]),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: "Type here...",
          ),
        ),
      ).paddingAll(10),
      StreamBuilder<bool>(
          initialData: false,
          stream: _showFuelReceive,
          builder: (context, snapshot) {
            return snapshot.data!
                ? Column(
                    children: <Widget>[
                      TitleAndWidgetShadow(
                        title: 'Fuel Type',
                        child: FormBuilderDropdown(
                          name: "fuelType",
                          hint: Text('Fuel Type'),
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                          items: ['Diesel', 'Petrol']
                              .map((option) => DropdownMenuItem(value: option, child: Text("$option")))
                              .toList(),
                          icon: const Icon(Icons.expand_more, size: 25),
                        ),
                      ).paddingAll(10),
                      TitleAndWidgetShadow(
                        title: 'Fuel Received',
                        child: FormBuilderTextField(
                          key: Key("fuelReceived"),
                          validator: FormBuilderValidators.compose(
                              [FormBuilderValidators.required(), FormBuilderValidators.numeric()]),
                          name: 'fuelReceived',
                          decoration: InputDecoration(hintText: 'Fuel Received'),
                          keyboardType: TextInputType.number,
                        ),
                      ).paddingAll(10),
                    ],
                  )
                : const SizedBox();
          }),
      TitleAndWidgetShadow(
        title: 'Remarks',
        child: FormBuilderTextField(
          key: Key("remarks"),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
          name: 'remarks',
          decoration: InputDecoration(hintText: 'Remarks'),
        ),
      ).paddingAll(10),
    ];

    var newList = [
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
                  if (_selectVehicleFormKey.currentState!.saveAndValidate()) {
                    var data = _selectVehicleFormKey.currentState!.value;
                    // data['driver'] = driverID;
                    // data['vehicleID'] = vehicleID;
                    _submit(data);
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
      20.verticalSpace,
    ];

    return [...myFormList, ...newList];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: initStateFetching
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Select Your Vehicle',
                    style: Theme.of(context).textTheme.headline5!.text244F4E.semiBold,
                  ),
                  10.verticalSpace,
                  Expanded(
                    child: SingleChildScrollView(
                      child: FormBuilder(
                        key: _selectVehicleFormKey,
                        child: Column(
                          children: _buildFormChildren(),
                        ),
                      ),
                    ),
                  ),
                ],
              ).paddingHorizontal(15)
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
