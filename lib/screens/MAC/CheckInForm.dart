import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
          iconTheme: const IconThemeData(color: Colors.black),
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

  const CheckInForm({Key? key, this.maintenanceType}) : super(key: key);

  @override
  State<CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final dioClient = AuthedDio.instance.dio;

  final SuggestionsController<dynamic> _vehicleTA = SuggestionsController<dynamic>();
  final SuggestionsController<dynamic> _handoverTA = SuggestionsController<dynamic>();

  final GlobalKey<FormBuilderState> _checkInFormKey = GlobalKey<FormBuilderState>();

  dynamic data;
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

  final TextEditingController _serviceTextController = TextEditingController();

  // Add Value into CheckBox
  var typeOfServicesValues = const ["AVI"];
  var typeOfServicesOptions = const [
    FormBuilderFieldOption(value: "AVI"),
  ];
  void _onChanged(dynamic val) {
    debugPrint(val.toString());
  }

  void setVehicleNumber(vehicle) {
    debugPrint('$vehicle');
    setState(() {
      vehicleID = "${vehicle['id']}";
      vehicleModel = "${vehicle['model']}";
    });
  }

  void setHandoverDriver(driver) {
    debugPrint('$driver');
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
    final auth = jsonDecode(authString as String);
    final userName = auth['user']['name'] as String;
    final id = auth['user']['id'];
    debugPrint('Username: $userName');

    setState(() {
      base = auth['user']['base'] != null ? "${auth['user']['base']['id']}" : "";
      name = userName;
      userID = '$id';
    });
  }

// Get List of vehicle from server
  Future<List> getVehicles(pattern) async {
    debugPrint('Pattern: $pattern');
    debugPrint('State: $vehicleModel');
    List list;
    try {
      var dio = await dioClient;
      var result =
          await dio.get("/vehicles?_limit=5&sub_unit.base=$base&vehicleNumber=$pattern");
      list = result.data as List;

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
    debugPrint('Pattern: $pattern');
    List list;
    try {
      var dio = await dioClient;
      var result1 =
          await dio.get("/users?role.type=driver&_limit=5&name_contains=$pattern");
      var result2 = await dio
          .get("/users?otherRoles.type=driver&_limit=5&name_contains=$pattern");
      list = [...result1.data as List, ...result2.data as List];
      debugPrint(list.toString());
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

  void onToolRemove(int index) {
    setState(() {
      listOfItems[index] = null;
    });
  }

  void onServiceRemove(int index) {
    setState(() {
      typeOfServices[index] = null;
    });
  }

  // Add New Item fields in list
  void addNewItem() {
    debugPrint('The Length of List is ${listOfItems.length}');
    final int index = listOfItems.length;
    setState(() {
      listOfItems.add(
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
                width: MediaQuery.of(context).size.width * 0.4,
                child: FormBuilderTextField(
                  key: Key('$index'),
                  validator: FormBuilderValidators.compose(
                      [FormBuilderValidators.required(errorText: 'Cannot be empty!')]),
                  name: 'name$index',
                  controller: TextEditingController(),
                  decoration: const InputDecoration(
                    hintText: 'Type Here...',
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
                child: FormBuilderTextField(
                  key: Key('$index'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Cannot be empty!'),
                    FormBuilderValidators.numeric(errorText: 'Must be numeric!'),
                    FormBuilderValidators.min(1, errorText: 'Must be > 0!')
                  ]),
                  name: 'quantity$index',
                  controller: TextEditingController(),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Type Here',
                      counterStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 4.0,
                          color: Colors.black)),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onToolRemove(index),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void setMyItem(BuildContext context) {
    if (!itemSet) {
      setState(() {
        listOfItems.add(
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 25, 20, 0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Cannot be empty!')
                    ]),
                    name: 'name',
                    decoration: const InputDecoration(
                      hintText: 'Type Here...',
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: FormBuilderTextField(
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Cannot be empty!'),
                      FormBuilderValidators.numeric(errorText: 'Must be numeric!'),
                      FormBuilderValidators.min(1, errorText: 'Must be > 0!')
                    ]),
                    name: 'quantity',
                    controller: TextEditingController(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: 'Type Here',
                        counterStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 4.0,
                            color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        );
      });

      typeOfServices.add(SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: FormBuilderCheckboxGroup(
          activeColor: Theme.of(context).primaryColor,
          decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Types of Services',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
          name: 'service',
          initialValue: const ['AVI'],
          options: const [FormBuilderFieldOption(value: 'AVI')],
        ),
      ));
    }
    setState(() {
      itemSet = true;
    });
  }

  // Add New Service
  void addNewService(String service) {
    debugPrint('The Length of List is ${typeOfServices.length}');
    final int index = typeOfServices.length;
    setState(() {
      typeOfServices.add(Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: FormBuilderCheckboxGroup(
                key: Key('$index'),
                activeColor: Theme.of(context).primaryColor,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    // labelText: "Types of Services",
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black)),
                name: 'service$index',
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
      ));
      newTypeOfService = '';
    });
  }

  // On Submit Checkout Form
  Future<void> onSubmitForm(Map<String, dynamic> data) async {
    setState(() {
      submitting = true;
    });

    final List names = [];
    final List quantities = [];

    data.forEach((key, value) {
      if (key.contains('name')) {
        names.add(value);
      } else if (key.contains('quantity')) {
        quantities.add(value);
      }
    });

    // List of Tools
    final List basicIssueTools = [];

    for (var i = 0; i < names.length; i++) {
      if (listOfItems[i] != null) {
        basicIssueTools.add({'name': names[i], 'quantity': quantities[i]});
      }
    }

    final List allServices = [];
    data.forEach((key, value) {
      if (key.contains('service') && value is List && value.isNotEmpty) {
        allServices.add(value.first);
      }
    });

    data['services'] = allServices;

    data['basicIssueTools'] = basicIssueTools.toList();
    data['expectedCheckoutTime'] =
        '${data['expectedCheckoutTime'].toString().substring(11, 16)}:00.000';
    data['dateIn'] = (data['dateIn'] as DateTime).toIso8601String();
    data['expectedCheckoutDate'] =
        (data['expectedCheckoutDate'] as DateTime).toIso8601String();
    data['maintenanceType'] = widget.maintenanceType;
    data['vehicle'] = vehicleID;
    data['handedOverBy'] = handOverDriverID;
    data['attendedBy'] = userID;

    final dio = await dioClient;

    final List images = data['images'] as List? ?? [];

    data.remove('images');

    final response = await dio.post('/vehicle-servicings', data: json.encode(data));

    Future<void> uploadImage(dynamic image) async {
      final file = image as File;
      final formData = FormData();
      formData.fields.add(MapEntry('ref', response.data['ref'] as String));
      formData.fields
          .add(MapEntry('refId', response.data['refId'].toString()));
      formData.fields.add(MapEntry('field', response.data['field'] as String));
      // Add permission to upload images on Strapi
      formData.files
          .add(MapEntry('files', await MultipartFile.fromFile(file.path)));
      await dio.post('/upload', data: formData);
      debugPrint('Image Added!');
    }

    for (final image in images) {
      await uploadImage(image);
    }

    if (!mounted) return;

    setState(() {
      submitting = false;
    });
    showAlertDialog(context, 'Success', 'Vehicle is Checked-In successfully!');
  }

  @override
  Widget build(BuildContext context) {
    setMyItem(context);

    return FormBuilder(
      key: _checkInFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'unitSquardon',
              decoration: const InputDecoration(
                  labelText: 'Unit Squardon',
                  hintText: 'Type Here... ',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'telephoneNo',
              decoration: const InputDecoration(
                  labelText: 'Telephone No.',
                  hintText: 'Type Here...',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTypeAhead<dynamic>(
              name: 'vehicleNumber',
              suggestionsController: _vehicleTA,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (val) {
                  if (vehicleModel == null) return 'Please enter a valid vehicle number';
                  return null;
                }
              ]),
              decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
              itemBuilder: (context, itemData) {
                return itemData != null && itemData.length != 0
                    ? ListTile(title: Text('${itemData['vehicleNumber']}'))
                    : const SizedBox.shrink();
              },
              suggestionsCallback: (pattern) async {
                return getVehicles(pattern);
              },
              selectionToTextTransformer: (suggestion) {
                if (suggestion != '') {
                  return suggestion['vehicleNumber'] as String;
                }
                return '';
              },
              onSuggestionSelected: (suggestion) => setVehicleNumber(suggestion),
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'No Vehicles Found!',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text('Model',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Colors.black)),
          ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                child: Text(vehicleModel ?? 'N/A',
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        color: Colors.black)),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderDropdown(
              name: 'frontSensorTag',
              decoration: const InputDecoration(
                  labelText: 'Fuel Sensor Tag',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
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
                    'Basic Issue Tools',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: const Text('In(QTY)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: Colors.black)),
                )
              ],
            ),
          ),
          // Column(children: listOfItems),
          for (final item in listOfItems)
            if (item != null) item,
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  )),
                  side: WidgetStatePropertyAll<BorderSide>(
                    BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                onPressed: addNewItem,
                child: const Text(
                  'Add Another Item',
                  style: TextStyle(color: Colors.black),
                ),
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
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'defect',
              decoration: const InputDecoration(
                  labelText: 'Defect',
                  hintText: 'Type Here...',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                name: 'dateIn',
                onChanged: _onChanged,
                inputType: InputType.date,
                decoration: const InputDecoration(
                    labelText: 'Date In',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black),
                    suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                    )),
                // initialDate: ,
                // validator: (val) => null,
                // initialTime: TimeOfDay(hour: 8, minute: 0),
                initialValue: DateTime.now(),
                format: DateFormat('dd MMMM yyyy')
                // readonly: true,
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                name: 'expectedCheckoutDate',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onChanged: _onChanged,
                inputType: InputType.date,
                decoration: const InputDecoration(
                    labelText: 'Expected Check-out Date',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black),
                    suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.date_range), // myIcon is a 48px-wide widget.
                    )),
                // initialDate: ,
                // validator: (val) => null,
                // initialTime: TimeOfDay(hour: 8, minute: 0),
                initialValue: DateTime.now(),
                format: DateFormat('dd MMMM yyyy')
                // readonly: true,
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'speedoReading',
              decoration: const InputDecoration(
                  labelText: 'Speedo Reading',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'swdReading',
              decoration: const InputDecoration(
                  labelText: 'SWD Reading',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),

          // Second Logic
          for (final item in typeOfServices)
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: FormBuilderTextField(
                    onChanged: (value) {
                      setState(() {
                        newTypeOfService = value ?? '';
                      });
                    },
                    name: 'newType',
                    controller: _serviceTextController,
                    decoration: InputDecoration(
                      hintText: 'Type Here...',
                      labelText: 'Add New Service',
                      errorText: _validate ? "New Service Can't Be Empty" : null,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (newTypeOfService.isNotEmpty) {
                        addNewService(newTypeOfService);
                        _serviceTextController.text = '';
                      } else {
                        setState(() {
                          _validate = _serviceTextController.text.isEmpty;
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
            padding: const EdgeInsets.all(10),
            child: FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              name: 'cw',
              decoration: const InputDecoration(
                  labelText: 'Corrective Maintenance',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderTypeAhead<dynamic>(
              name: 'handedOverBy',
              suggestionsController: _handoverTA,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (val) {
                  if (handOverDriverID == null) {
                    return 'Please enter a valid name. ';
                  }
                  return null;
                }
              ]),
              decoration: const InputDecoration(
                  labelText: 'Handed Over By',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
              itemBuilder: (context, itemData) {
                return itemData != null && itemData.length != 0
                    ? ListTile(title: Text('${itemData['name']}'))
                    : const SizedBox.shrink();
              },
              suggestionsCallback: (pattern) async {
                return getDrivers(pattern);
              },
              selectionToTextTransformer: (suggestion) {
                if (suggestion != '') {
                  return suggestion['name'] as String;
                }
                return '';
              },
              onSuggestionSelected: (suggestion) => setHandoverDriver(suggestion),
              noItemsFoundBuilder: (context) => const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'No Drivers Found!',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderDateTimePicker(
                name: 'expectedCheckoutTime',
                onChanged: _onChanged,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                inputType: InputType.time,
                decoration: const InputDecoration(
                    labelText: 'Time',
                    hintText: 'HH-MM',
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black),
                    suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.0),
                      child: Icon(Icons.access_time), // myIcon is a 48px-wide widget.
                    )),
                format: DateFormat('h:mma')
                // readonly: true,
                ),
          ),
          const Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text('Attended By(IEPL)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                child: Text(
                  name ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15.0,
                      color: Colors.black),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FormBuilderDropdown(
              name: 'vehicle',
              decoration: const InputDecoration(
                  labelText: 'Vehicle / Motorcycle',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black)),
              initialValue: 'Vehicle',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              items: const ['Vehicle', 'Motorcycle']
                  .map((vehicle) => DropdownMenuItem(value: vehicle, child: Text(vehicle)))
                  .toList(),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: submitting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        )),
                        side: WidgetStatePropertyAll<BorderSide>(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onPressed: () {
                        if (_checkInFormKey.currentState!.saveAndValidate()) {
                          onSubmitForm(
                            _checkInFormKey.currentState!.value
                                .map((key, value) => MapEntry(key, value)),
                          );
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
