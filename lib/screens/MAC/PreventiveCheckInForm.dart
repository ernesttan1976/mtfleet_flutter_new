import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/extension/extension.dart';
import 'package:transport_flutter/components/form_builder_typehead.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/constants.dart' as constants;
import 'package:transport_flutter/util/currentUserData.dart';

class PreventiveCheckInFormScreen extends StatelessWidget {
  final String maintenanceType;

  const PreventiveCheckInFormScreen({Key? key, required this.maintenanceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '${title()} Check-in Form',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: PreventiveCheckInForm(maintenanceType: maintenanceType).paddingHorizontal(15));
  }

  String title() {
    if (maintenanceType == 'Preventive') {
      return 'Preventive';
    }
    if (maintenanceType == 'Corrective') {
      return 'Corrective';
    }
    if (maintenanceType == 'AVI') {
      return 'Annual Vehicle Inspection\n';
    }
    return '';
  }
}

class PreventiveCheckInForm extends StatefulWidget {
  final String maintenanceType;

  const PreventiveCheckInForm({Key? key, required this.maintenanceType}) : super(key: key);

  @override
  State<PreventiveCheckInForm> createState() => _PreventiveCheckInFormState();
}

class _PreventiveCheckInFormState extends State<PreventiveCheckInForm> {
  final dioClient = AuthedDio.instance.dio;

  final GlobalKey<FormBuilderState> _preventiveCheckInFormKey = GlobalKey<FormBuilderState>();

  String base = "";
  bool autoValidate = true;
  bool readOnly = false;
  bool submitting = false;
  bool showSegmentedControl = true;
  bool itemSet = false;
  String? userID;
  String? name;
  String? vehicleModel;
  List listOfItems = [];
  List typeOfServices = [];

  final DateTime _checkoutTime = DateTime.now();

  String? vehicleID;
  String? handOverDriverID;

  String newTypeOfService = "";
  final logger = Logger();

  // Add Value into CheckBox
  var typeOfServicesValues = ["AVI"];
  var typeOfServicesOptions = [
    const FormBuilderFieldOption(value: "AVI"),
  ];

  void setVehicleNumber(vehicle) {
    setState(() {
      vehicleID = "${vehicle['id']}";
      vehicleModel = "${vehicle['model']}";
    });
  }

  void setHandoverDriver(driver) {
    setState(() {
      handOverDriverID = "${driver['id']}";
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final userName = auth['user']['name'];
    final id = auth['user']['id'];

    setState(() {
      base = auth['user']['base'] != null ? "${auth['user']['base']['id']}" : "";
      name = "$userName";
      userID = "$id";
    });
  }

// Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    List list;
    try {
      var dio = await dioClient;
      var result = await dio.get("/vehicles?_limit=5&sub_unit.base=$base&vehicleNumber=$pattern");
      list = result.data;

      setState(() {
        vehicleID = null;
        vehicleModel = null;
      });
    } catch (e) {
      list = [];
    }
    return list;
  }

// Get List of driver from server
  Future<List> getDrivers(pattern) async {
    List list;
    try {
      var dio = await dioClient;
      var result1 = await dio.get("/users?role.type=driver&_limit=5&name_contains=$pattern");
      var result2 = await dio.get("/users?otherRoles.type=driver&_limit=5&name_contains=$pattern");
      list = [...result1.data, ...result2.data];
      if (list.isEmpty) {
        setState(() {
          handOverDriverID = null;
        });
      }
    } catch (e) {
      list = [];
    }
    return list;
  }

  void onToolRemove(index) {
    setState(() {
      listOfItems[index] = null;
    });
  }

  void onServiceRemove(index) {
    setState(() {
      typeOfServices[index] = null;
    });
  }

  // Add New Item fields in list
  void addNewItem() {
    final index = listOfItems.length;
    setState(() {
      listOfItems.add(
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: FormBuilderTextField(
                key: Key("name$index"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "Cannot be empty!"),
                ]),
                name: "name$index",
                decoration: const InputDecoration(
                  hintText: "Type Here...",
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
              child: FormBuilderTextField(
                key: Key("quantity$index"),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "Cannot be empty!"),
                  FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                  FormBuilderValidators.min(1, errorText: "Must be > 0!"),
                ]),
                name: "quantity$index",
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Type Here",
                  counterStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 4.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
              width: MediaQuery.of(context).size.width * 0.1,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onToolRemove(index),
              ),
            ),
          ],
        ),
      );
    });
  }

  void setMyItem(BuildContext context) {
    if (!itemSet) {
      setState(() {
        listOfItems.add(
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Cannot be empty!"),
                  ]),
                  name: "name",
                  decoration: const InputDecoration(
                    hintText: "Type Here...",
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
                child: FormBuilderTextField(
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: "Cannot be empty!"),
                    FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                    FormBuilderValidators.min(1, errorText: "Must be > 0!"),
                  ]),
                  name: "quantity",
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Type Here",
                    counterStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 4.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        typeOfServices.add(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                "Type of Preventive Maintenance ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      });
    }
    itemSet = true;
  }

  // Add New Service
  void addNewService(String service) {
    final index = typeOfServices.length;
    setState(() {
      typeOfServices.add(
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: FormBuilderCheckboxGroup(
                  key: Key("service$index"),
                  activeColor: Theme.of(context).primaryColor,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  name: "service$index",
                  initialValue: [service],
                  options: [FormBuilderFieldOption(value: service)],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onServiceRemove(index),
                ),
              ),
            ],
          ),
        ),
      );
      newTypeOfService = "";
    });
  }

  // On Submit Checkout Form
  void onSubmitForm(Map<String, dynamic> data) async {
    try {
      setState(() {
        submitting = true;
      });
      final names = <String>[];
      final quantities = <String>[];

      data.forEach((key, value) {
        if (key.contains("name")) {
          names.add(value as String);
        } else if (key.contains("quantity")) {
          quantities.add(value as String);
        }
      });

      final basicIssueTools = <Map<String, dynamic>>[];

      for (var i = 0; i < names.length; i++) {
        if (listOfItems[i] != null) {
          basicIssueTools.add({
            "name": names[i],
            "quantity": num.parse(quantities[i]),
          });
        }
      }

      final typeData = <String, dynamic>{};

      if (widget.maintenanceType == 'Preventive') {
        typeData.addAll({
          "preventiveMaintenance": jsonEncode({
            "defect": data['service'],
            "type": data['service'],
          }),
        });
      }
      if (widget.maintenanceType == 'Corrective') {
        typeData.addAll({
          "correctiveMaintenance": jsonEncode({
            "correctiveMaintenance": data['correctiveMaintenance'],
          }),
        });
      }
      if (widget.maintenanceType == 'AVI') {
        typeData.addAll({
          "annualVehicleInspection": jsonEncode({
            "defect": data['defect'],
          }),
        });
      }

      final imagesMultipart = <MultipartFile>[];
      final images = data['images'] as List?;
      if (images != null) {
        for (final img in images) {
          final file = img as File;
          final multipartImage = await MultipartFile.fromFile(file.path);
          imagesMultipart.add(multipartImage);
        }
      }

      final checkoutDate = data['expectedCheckoutDate'] as DateTime;

      final formData = FormData.fromMap({
        "workCenter": data['workCentre'],
        "telephoneNo": data['telephoneNo'],
        'images': imagesMultipart.isNotEmpty ? imagesMultipart : [],
        "speedoReading": data['speedoReading'],
        "swdReading": data['swdReading'],
        "dateIn": (data['dateIn'] as DateTime).toUtc().toIso8601String(),
        "expectedCheckoutDate": checkoutDate.toUtc().toIso8601String(),
        "vehicleId": int.parse(vehicleID!),
        "expectedCheckoutTime": _checkoutTime.toUtc().toIso8601String(),
        "handedBy": data['handedBy'],
        "attender": data['attender'],
        "frontSensorTag": data['frontSensorTag'],
        "checkInType": widget.maintenanceType,
        "basicIssueTools": jsonEncode(basicIssueTools.toList()),
        ...typeData,
      });
      logger.e(formData.fields.toString());
      Dio dio = Dio(
        BaseOptions(
          baseUrl: constants.SERVER_URI_API,
          contentType: 'multipart/form-data',
          headers: {
            "Authorization": "Bearer ${await storage.read(key: constants.storageBearer)}",
            'Accept': 'application/json',
          },
        ),
      );

      final response = await dio.post("/check-in", data: formData);
      setState(() {
        submitting = false;
      });
      final successMessage = response.statusMessage ?? 'Success';
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", successMessage);
      } else {
        final failureMessage = response.statusMessage ?? 'Failure';
        showAlertDialog(context, "Failure", failureMessage, isPop: false);
      }
    } on DioException catch (e) {
      setState(() {
        submitting = false;
      });
      logger.e("${e.response}");
      showAlertDialog(context, "Failure Error", e.response?.data["message"] ?? 'Unknown error', isPop: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    setMyItem(context);

    return Stack(
      children: <Widget>[
        FormBuilder(
          key: _preventiveCheckInFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    name: "workCentre",
                    decoration: const InputDecoration(
                      labelText: "Work Centre",
                      hintText: "Type Here... ",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    name: "telephoneNo",
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Telephone No.",
                      hintText: "Type Here...",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FormBuilderTypeAhead<dynamic>(
                    name: "vehicleNumber",
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      (val) {
                        if (vehicleModel == null) return "Please enter a valid vehicle number";
                        return null;
                      },
                    ]),
                    itemBuilder: (context, itemData) {
                      if (itemData == null || itemData['vehicleNumber'] == null) {
                        return const SizedBox.shrink();
                      }
                      return ListTile(title: Text(itemData['vehicleNumber'] as String));
                    },
                    suggestionsCallback: (pattern) async {
                      return await getVehicles(pattern);
                    },
                    selectionToTextTransformer: (suggestion) {
                      if (suggestion == null || suggestion == "") {
                        return "";
                      }
                      return suggestion['vehicleNumber'] as String;
                    },
                    onSuggestionSelected: (suggestion) => setVehicleNumber(suggestion),
                    noItemsFoundBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "No Vehicles Found!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Vehicle Number",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: const Text(
                        'Model',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text(
                        vehicleModel ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.maintenanceType == 'Preventive')
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FormBuilderDropdown(
                      name: "service",
                      decoration: const InputDecoration(
                        labelText: "Type of Preventive Maintenance",
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                      hint: const Text('Please Select'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      items: const [
                        'A1',
                        'A2',
                        'B',
                        'ESC',
                        '5K',
                        '10k',
                        '15K',
                        '20K',
                        '25K',
                        '30K',
                        '35K',
                        '40K',
                        '50K',
                        '60K',
                        '70K',
                        '80K',
                        '90K',
                        '100K',
                        '110K',
                        '120K',
                        '130K',
                        '140K',
                        '150K',
                        '160K',
                        '170K',
                        '180K',
                        '190K',
                        '200K',
                      ].map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: FormBuilderDropdown(
                    name: "frontSensorTag",
                    decoration: const InputDecoration(
                      labelText: "Fuel Sensor Tag",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    hint: const Text('Yes/No'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    items: const ['Yes', 'No']
                        .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: const Text(
                          "Basic Issue Tools",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text(
                          "In(QTY)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ... rest of the widget tree remains unchanged ...
              ],
            ),
          ),
        ),
      ],
    );
  }
}
