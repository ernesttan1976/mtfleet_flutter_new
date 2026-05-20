import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/components/components.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/extensions/extensions.dart';
import 'package:transport_flutter/main.dart';
import 'package:transport_flutter/models/models.dart';

class ELogBookFormScreen extends StatefulWidget {
  final int? destinationId;
  final Destination? destination;
  final TripDetailModel? detailTrip;
  final bool? isEnd;
  final TimeOfDay? endTime;

  ELogBookFormScreen({this.destinationId, this.destination, this.detailTrip, this.isEnd = false, this.endTime});

  @override
  _ELogBookFormScreenState createState() => _ELogBookFormScreenState();
}

class _ELogBookFormScreenState extends State<ELogBookFormScreen> {
  final GlobalKey<FormBuilderState> _elogbookFormKey = GlobalKey<FormBuilderState>();

  final dioClient = AuthedDio.instance.dio;

  bool _isLoading = false;

  num _currentMeterReading = 0;

  @override
  void initState() {
    super.initState();
    _getLastMeterReading();
  }

  final _textTotalDistanceKm = TextEditingController();

  void _getLastMeterReading() async {
    final _dio = await dioClient;
    try {
      final res = await _dio.get('/vehicles/last-meter-reading/${widget.detailTrip?.vehiclesId}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        _currentMeterReading = res.data['meterReading'] ?? 0;
      } else {
        showAlertDialog(context, 'Error', res.statusMessage);
        return;
      }
    } on DioException catch (e) {
      showAlertDialog(context, 'Error', e.response!.data["message"]);
    }
  }

  void onSubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final _value = _elogbookFormKey.currentState!.value;
      final _data = {
        "destinationId": widget.destinationId,
        "currentMeterReading": int.parse(_value['currentMeterReading']),
        // "details": _value['details'],
        "ELog": {
          "endTime":
              DateTime.now().copyWith(hourN: widget.endTime?.hour, p: widget.endTime?.minute).toUtc().toIso8601String(),
          "stationaryRunningTime": int.parse(_value['stationaryRunningTime']),
          "totalDistance": int.parse(_value['totalDistance']),
          // "fuelReceived": int.parse(_value['fuelReceived']),
          // "POSONumber": int.parse(_value['POSONumber']),
          // "fuelType": _value['FuelType'],
          // "requisitionerPurpose": _value['requisitionerPurpose'],
          "remarks": _value['remarks']
        }
      };
      logger.e(_data);
      final _dio = await dioClient;
      final _res = await _dio.post('/trips/end-destination', data: _data);
      if (_res.statusCode == 201) {
        if (widget.isEnd!) {
          onCompletedTrip();
        } else {
          showAlertDialog(context, 'Success', _res.statusMessage);
        }
      }
      setState(() {
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, ' Dio Error', "${e.response?.data["message"]}", isPop: false);
    }
  }

  void onCompletedTrip() async {
    print("Trip End My Darling");
    setState(() {
      _isLoading = true;
    });
    try {
      var dio = await dioClient;
      var response = await dio.patch("/trips/end/${widget.detailTrip?.id}");
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        showAlertDialog(context, 'Success', response.statusMessage);
      } else {
        showAlertDialog(context, 'Error', response.statusMessage);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlertDialog(context, 'Error', e);
    }
  }

  void _questionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: new Text('You clicked on'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Container(
            child: Text(
              "You have completed the last trip\nDo you want end the trip session?",
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                width: MediaQuery.of(context).size.width * 1.0,
                height: 50,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).primaryColor,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onSubmit();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                        ),
                        onPressed: () => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pop(),
                        },
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        );
      },
    );
  }

  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ELogbook',
                  style: _themeData.textTheme.headlineSmall!.text244F4E.semiBold,
                ).paddingOnly(left: 25),
                Expanded(
                  child: FormBuilder(
                    key: _elogbookFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          30.verticalSpace,
                          Text(
                            'Trip Date',
                            style: _themeData.textTheme.titleSmall?.semiBold,
                          ).paddingOnly(left: 10),
                          5.verticalSpace,
                          Text(
                                  widget.detailTrip?.tripDate == null
                                      ? '--'
                                      : widget.detailTrip!.tripDate!.formatDateddMMMyyyy,
                                  style: _themeData.textTheme.titleMedium!.medium)
                              .paddingOnly(left: 10),
                          20.verticalSpace,
                          Text(
                            'Time Start',
                            style: _themeData.textTheme.titleSmall?.semiBold,
                          ).paddingOnly(left: 10),
                          5.verticalSpace,
                          Text(
                                  widget.destination?.eLog?.startTime == null
                                      ? '--'
                                      : widget.destination!.eLog!.startTime!.formatDateTime('HH:mm'),
                                  style: _themeData.textTheme.titleMedium!.medium)
                              .paddingOnly(left: 10),
                          20.verticalSpace,
                          Text(
                            'Time Arrived',
                            style: _themeData.textTheme.titleSmall!.semiBold,
                          ).paddingOnly(left: 10),
                          5.verticalSpace,
                          Text(
                                  DateTime.now()
                                      .copyWith(hourN: widget.endTime!.hour, p: widget.endTime!.minute)
                                      .formatDateTime('HH:mm'),
                                  style: _themeData.textTheme.titleMedium!.medium)
                              .paddingOnly(left: 10),
                          20.verticalSpace,
                          TitleAndWidgetShadow(
                            title: 'Stationary Running Time (in minutes)',
                            child: FormBuilderTextField(
                              key: Key("stationaryRunningTime"),
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required(), FormBuilderValidators.numeric()]),
                              name: 'stationaryRunningTime',
                              decoration: InputDecoration(hintText: 'Type here...'),
                              keyboardType: TextInputType.number,
                            ),
                          ).paddingAll(10),
                          TitleAndWidgetShadow(
                            title: 'Meter Reading At Journey’s End (if not working, write “ N,W, ”)',
                            child: FormBuilderTextField(
                              name: "currentMeterReading",
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.numeric(errorText: "Must be numeric!"),
                                FormBuilderValidators.min(0)
                              ]),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Type here...",
                              ),
                              onChanged: (val) {
                                print("Current meter " + _currentMeterReading.toString());
                                if ((val as String).isEmpty) {
                                  _textTotalDistanceKm.clear();
                                } else {
                                  if (int.parse(val) - _currentMeterReading > 0) {
                                    _textTotalDistanceKm.text = '${int.parse(val) - _currentMeterReading}';
                                  } else {
                                    _textTotalDistanceKm.text = '0';
                                  }
                                                                }
                              },
                            ),
                          ).paddingAll(10),
                          TitleAndWidgetShadow(
                            title: 'Total Distance in KM',
                            child: FormBuilderTextField(
                              controller: _textTotalDistanceKm,
                              key: Key("totalDistance"),
                              validator: FormBuilderValidators.compose(
                                  [FormBuilderValidators.required(), FormBuilderValidators.numeric()]),
                              name: 'totalDistance',
                              decoration: InputDecoration(hintText: 'System calculated'),
                              keyboardType: TextInputType.number,
                              readOnly: true,
                            ),
                          ).paddingAll(10),
                          TitleAndWidgetShadow(
                            title: 'Remarks',
                            child: FormBuilderTextField(
                              key: Key("remarks"),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                              name: 'remarks',
                              minLines: 3,
                              maxLines: 10,
                              decoration: InputDecoration(hintText: 'Remarks'),
                            ),
                          ).paddingAll(10),
                          // TitleAndWidgetShadow(
                          //   title: 'Details',
                          //   child: FormBuilderTextField(
                          //     key: Key("details"),
                          //     validators: [
                          //       FormBuilderValidators.required(context,),
                          //     ],
                          //     name: 'details',
                          //     decoration: InputDecoration(hintText: 'Details'),
                          //   ),
                          // ).paddingAll(10),
                          // TitleAndWidgetShadow(
                          //   title: 'Fuel Type',
                          //   child: FormBuilderDropdown(
                          //     name: "FuelType",
                          //     hint: Text('Fuel Type'),
                          //     onChanged: (val) {},
                          //     validator: FormBuilderValidators.compose([FormBuilderValidators.required(context)]),
                          //     items: ['Diesel'].map((option) => DropdownMenuItem(value: option, child: Text("$option"))).toList(),
                          //     icon: const Icon(Icons.expand_more, size: 25),
                          //   ),
                          // ).paddingAll(10),
                          // TitleAndWidgetShadow(
                          //   title: 'Fuel Received',
                          //   child: FormBuilderTextField(
                          //     key: Key("fuelReceived"),
                          //     validators: [FormBuilderValidators.required(context,), FormBuilderValidators.numeric(context,)],
                          //     name: 'fuelReceived',
                          //     decoration: InputDecoration(hintText: 'Fuel Received'),
                          //     keyboardType: TextInputType.number,
                          //   ),
                          // ).paddingAll(10),
                          // TitleAndWidgetShadow(
                          //   title: 'POSONumber',
                          //   child: FormBuilderTextField(
                          //     key: Key("POSONumber"),
                          //     validators: [FormBuilderValidators.required(context,), FormBuilderValidators.numeric(context,)],
                          //     name: 'POSONumber',
                          //     decoration: InputDecoration(hintText: 'POSONumber'),
                          //     keyboardType: TextInputType.number,
                          //   ),
                          // ).paddingAll(10),
                          // TitleAndWidgetShadow(
                          //   title: 'Requisitioner Purpose',
                          //   child: FormBuilderTextField(
                          //     key: Key("requisitionerPurpose"),
                          //     validators: [
                          //       FormBuilderValidators.required(context,),
                          //     ],
                          //     name: 'requisitionerPurpose',
                          //     decoration: InputDecoration(hintText: 'Requisitioner Purpose'),
                          //   ),
                          // ).paddingAll(10),
                          30.verticalSpace,
                          OutlinedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )),
                              side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                            ),
                            onPressed: () {
                              if (_elogbookFormKey.currentState!.saveAndValidate()) {
                                if (widget.isEnd!) {
                                  _questionAlert();
                                } else {
                                  onSubmit();
                                }
                              }
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(color: Colors.black),
                            ),
                          ).fullWidth.paddingAll(10),
                          20.verticalSpace,
                        ],
                      ),
                    ),
                  ).paddingHorizontal(15),
                ),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ));
  }
}
