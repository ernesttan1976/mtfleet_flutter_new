import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/form_builder_typehead.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/util/currentUserData.dart';

class CheckInFormScreen extends StatelessWidget {
  final String? maintenanceType;

  const CheckInFormScreen({Key? key, this.maintenanceType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Check-in Form',
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
                  child: CheckInForm(
                    maintenanceType: maintenanceType!,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class CheckInForm extends StatefulWidget {
  final String? maintenanceType;

  CheckInForm({Key? key, this.maintenanceType}) : super(key: key);

  @override
  _CheckInFormState createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final dioClient = AuthedDio.instance.dio;

  final _vehicleTA = SuggestionsBoxController();
  final _handoverTA = SuggestionsBoxController();

  final GlobalKey<FormBuilderState> _checkInFormKey = GlobalKey<FormBuilderState>();

  var data;
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

  int toolsCount = 1;

  String? vehicleID;
  String? handOverDriverID;

  String newTypeOfService = "";
  bool _validate = false;

  TextEditingController _serviceTextController = new TextEditingController();

  // Add Value into CheckBox
  var typeOfServicesValues = ["AVI"];
  var typeOfServicesOptions = [
    FormBuilderFieldOption(value: "AVI"),
  ];
  ValueChanged _onChanged = (val) => print(val);

  void setVehicleNumber(vehicle) {
    print("$vehicle");
    setState(() {
      vehicleID = "${vehicle['id']}";
      vehicleModel = "${vehicle['model']}";
    });
  }

  void setHandoverDriver(driver) {
    print("$driver");
    setState(() {
      handOverDriverID = "${driver['id']}";
    });
  }

  @override
  void initState() {
    super.initState();
    this.loadUser();
  }

  loadUser() async {
    final authString = await getUser();
    final auth = jsonDecode(authString);
    final userName = auth['user']['name'];
    final id = auth['user']['id'];
    print("Username: $userName");

    setState(() {
      base = auth['user']['base'] != null ? "${auth['user']['base']['id']}" : "";
      name = "$userName";
      userID = "$id";
    });
  }

// Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    print("Pattern: $pattern");
    print("State: $vehicleModel");
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
    print("Pattern: $pattern");
    List list;
    try {
      var dio = await dioClient;
      var result1 = await dio.get("/users?role.type=driver&_limit=5&name_contains=$pattern");
      var result2 = await dio.get("/users?otherRoles.type=driver&_limit=5&name_contains=$pattern");
      list = [...result1.data, ...result2.data];
      print(list);
      if (list.length == 0) {
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

      typeOfServices.add(Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FormBuilderCheckboxGroup(
          activeColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
              border: InputBorder.none,
              labelText: "Types of Services",
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
          name: "service",
          initialValue: ["AVI"],
          options: [FormBuilderFieldOption(value: "AVI")],
        ),
      ));
    }
    setState(() {
      itemSet = true;
    });
  }

  // Add New Service
  void addNewService(String service) {
    print("The Length of List is ${typeOfServices.length}");
    int index = typeOfServices.length;
    setState(() {
      typeOfServices.add(Container(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: FormBuilderCheckboxGroup(
                key: Key("$index"),
                activeColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    // labelText: "Types of Services",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
                name: "service$index",
                initialValue: [service],
                options: [FormBuilderFieldOption(value: service)],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 15, 20, 0),
              width: MediaQuery.of(context).size.width * 0.1,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => onServiceRemove(index),
              ),
            ),
          ],
        ),
      ));
      newTypeOfService = "";
    });
  }

  // On Submit Checkout Form
  void onSubmitForm(var data) async {
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
      if (listOfItems[i] != null) basicIssueTools.add({"name": names[i], "quantity": quantities[i]});
    }

    List allServices = [];
    data.entries.forEach((e) {
      if (e.key.contains("service")) {
        if (e.value.length > 0) {
          String myService = e.value.first;
          allServices.add(myService);
        }
      }
    });

    data['services'] = allServices;

    data["basicIssueTools"] = basicIssueTools.toList();
    data["expectedCheckoutTime"] = data['expectedCheckoutTime'].toString().substring(11, 16) + ":00.000";
    data["dateIn"] = data["dateIn"].toIso8601String();
    data["expectedCheckoutDate"] = data["expectedCheckoutDate"].toIso8601String();
    data["maintenanceType"] = widget.maintenanceType;
    data["vehicle"] = vehicleID;
    data["handedOverBy"] = handOverDriverID;
    data["attendedBy"] = userID;

    var dio = await dioClient;

    List images = data['images'];

    data.remove("images");

    final response = await dio.post("/vehicle-servicings", data: json.encode(data));

    Future uploadImage(image) async {
      File file = image as File;
      FormData formData = FormData();
      formData.fields.add(MapEntry("ref", response.data["ref"]));
      formData.fields.add(MapEntry("refId", "${response.data["refId"]}"));
      formData.fields.add(MapEntry("field", response.data["field"]));
      // Add permission to upload images on Strapi
      formData.files.add(MapEntry("files", await MultipartFile.fromFile(file.path)));
      await dio.post("/upload", data: formData);
      print("Image Added!");
    }

    Future.forEach(images, uploadImage).then((value) {
      setState(() {
        submitting = false;
      });
      showAlertDialog(context, "Success", "Vehicle is Checked-In successfully!");
    });
  }

  @override
  Widget build(BuildContext context) {
    setMyItem(context);

    return FormBuilder(
      key: _checkInFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "unitSquardon",
              decoration: InputDecoration(
                  labelText: "Unit Squardon",
                  hintText: "Type Here... ",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "telephoneNo",
              decoration: InputDecoration(
                  labelText: "Telephone No.",
                  hintText: "Type Here...",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTypeAhead<dynamic>(
              name: "vehicleNumber",
              suggestionsBoxController: _vehicleTA,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (val) {
                  if (vehicleModel == null) return "Please enter a valid vehicle number";
                  return null;
                }
              ]),
              decoration: InputDecoration(
                  labelText: "Vehicle Number",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              itemBuilder: (context, itemData) {
                return itemData != null || itemData?.length != 0
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
              noItemsFoundBuilder: (context) => Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "No Vehicles Found!",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child:
                    Text('Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                child: Text(vehicleModel != null ? "$vehicleModel" : "N/A",
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15.0, color: Colors.black)),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderDropdown(
              name: "frontSensorTag",
              decoration: InputDecoration(
                  labelText: "Fuel Sensor Tag",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              hint: Text('Yes/No'),
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              items: ['Yes', 'No'].map((option) => DropdownMenuItem(value: option, child: Text("$option"))).toList(),
            ),
          ),
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
                  child: Text("In(QTY)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black)),
                )
              ],
            ),
          ),
          // Column(children: listOfItems),
          for (var item in listOfItems)
            if (item != null) item,
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

          ///IMAGE
          // Padding(
          //   padding: EdgeInsets.all(10),
          //   child: FormBuilderImagePicker(
          //     // validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
          //     name: "images",
          //     decoration: InputDecoration(
          //         labelText: "Condition of Vehicle",
          //         labelStyle: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontSize: 20.0,
          //             color: Colors.black)),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "defect",
              decoration: InputDecoration(
                  labelText: "Defect",
                  hintText: "Type Here...",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                name: "dateIn",
                onChanged: _onChanged,
                inputType: InputType.date,
                decoration: InputDecoration(
                    labelText: "Date In",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                    )),
                // initialDate: ,
                // validator: (val) => null,
                // initialTime: TimeOfDay(hour: 8, minute: 0),
                initialValue: DateTime.now(),
                format: new DateFormat('dd MMMM yyyy')
                // readonly: true,
                ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                name: "expectedCheckoutDate",
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                onChanged: _onChanged,
                inputType: InputType.date,
                decoration: InputDecoration(
                    labelText: "Expected Check-out Date",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                    )),
                // initialDate: ,
                // validator: (val) => null,
                // initialTime: TimeOfDay(hour: 8, minute: 0),
                initialValue: DateTime.now(),
                format: new DateFormat('dd MMMM yyyy')
                // readonly: true,
                ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "speedoReading",
              decoration: InputDecoration(
                  labelText: "Speedo Reading",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "swdReading",
              decoration: InputDecoration(
                  labelText: "SWD Reading",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),

          // Second Logic
          for (var item in typeOfServices)
            if (item != null) item,

          // Container(
          //   width: MediaQuery.of(context).size.width * 0.9,
          //   child: FormBuilderCheckboxList(
          //     activeColor: Theme.of(context).primaryColor,
          //     leadingInput: true,
          //     decoration: InputDecoration(
          //         border: InputBorder.none,
          //         labelText: "Types of Services",
          //         labelStyle: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontSize: 18.0,
          //             color: Colors.black)),
          //     name: "services",
          //     initialValue: typeOfServicesValues,
          //     options: typeOfServicesOptions,
          //   ),
          // ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                Container(
                  // padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: FormBuilderTextField(
                    onChanged: (value) {
                      setState(() {
                        newTypeOfService = value!;
                      });
                    },
                    name: "newType",
                    controller: _serviceTextController,
                    decoration: InputDecoration(
                      hintText: "Type Here...",
                      labelText: "Add New Service",
                      errorText: _validate ? 'New Service Can\'t Be Empty' : null,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 25, 20, 0),
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (newTypeOfService.length != 0) {
                        addNewService(newTypeOfService);
                        _serviceTextController.text = "";
                      } else {
                        setState(() {
                          _serviceTextController.text.isEmpty ? _validate = true : _validate = false;
                        });
                      }

                      // setState(() {
                      //   typeOfServicesOptions = [
                      //     ...typeOfServicesOptions,
                      //     FormBuilderFieldOption(
                      //       value: newTypeOfService,
                      //     )
                      //   ];
                      //   _mynewController.text = "";
                      // });
                      // print(typeOfServicesOptions);
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              name: "cw",
              decoration: InputDecoration(
                  labelText: "Corrective Maintenance",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderTypeAhead<dynamic>(
              name: "handedOverBy",
              suggestionsBoxController: _handoverTA,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (val) {
                  if (handOverDriverID == null) return "Please enter a valid name. ";
                }
              ]),
              decoration: InputDecoration(
                  labelText: "Handed Over By",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              itemBuilder: (context, itemData) {
                return itemData != null || itemData.length != 0
                    ? ListTile(title: Text("${itemData['name']}"))
                    : Container();
              },
              suggestionsCallback: (pattern) async {
                return await getDrivers(pattern);
              },
              selectionToTextTransformer: (suggestion) {
                if (suggestion != "") {
                  return "${suggestion['name']}";
                }
                return "";
              },
              onSuggestionSelected: (suggestion) => setHandoverDriver(suggestion),
              noItemsFoundBuilder: (context) => Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "No Drivers Found!",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                name: "expectedCheckoutTime",
                onChanged: _onChanged,
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                inputType: InputType.time,
                decoration: InputDecoration(
                    labelText: "Time",
                    hintText: "HH-MM",
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                    )),
                format: new DateFormat('h:mma')
                // readonly: true,
                ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text('Attended By(IEPL)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.black)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                child:
                    Text("$name", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15.0, color: Colors.black)),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FormBuilderDropdown(
              name: "vehicle",
              decoration: InputDecoration(
                  labelText: "Vehicle / Motorcycle",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
              initialValue: 'Vehicle',
              validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              items: ['Vehicle', 'Motorcycle']
                  .map((vehicle) => DropdownMenuItem(value: vehicle, child: Text("$vehicle")))
                  .toList(),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: submitting
                ? Center(
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
                      if (_checkInFormKey.currentState!.saveAndValidate()) {
                        onSubmitForm(_checkInFormKey.currentState!.value);
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
