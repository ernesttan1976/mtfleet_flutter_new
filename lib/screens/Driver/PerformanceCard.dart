import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request_client;

class PerformanceCardSection extends StatefulWidget {
  final dynamic uid;
  final dynamic userJoined;

  const PerformanceCardSection({Key? key, this.uid, this.userJoined}) : super(key: key);

  @override
  PerformanceCardSectionState createState() => PerformanceCardSectionState();
}

class PerformanceCardSectionState extends State<PerformanceCardSection> {
  final dioClient = AuthedDio.instance.dio;
  List<dynamic>? performanceCard;
  bool isEmpty = false;
  // TODO: remove this key if unused or wire it into the Scaffold. Keeping for now.
  final performanceCardScaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormBuilderState> _durationFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    getPerformanceCard();
  }

  void getPerformanceCard() async {
    try {
      var request = request_client.Request();
      final response = await request.get(Uri.parse("performance-card"));
      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          performanceCard = result;
        });
      } else if (response.statusCode == 401) {
        await storage.deleteAll();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showAlertDialog(context, 'Error', response.body, isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString(), isPop: false);
    }
  }

  void getDownloadDates() {
    print("USER JOINED: ${widget.userJoined}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Duration'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: SizedBox(
              height: 320,
              child: FormBuilder(
                key: _durationFormKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: FormBuilderDateRangePicker(
                        firstDate: DateTime.parse(widget.userJoined).subtract(const Duration(days: 1)),
                        lastDate: DateTime.now(),
                        initialValue: DateTimeRange(
                          start: DateTime.parse(widget.userJoined),
                          end: DateTime.now().subtract(const Duration(minutes: 10)),
                        ),
                        format: DateFormat("E dd MMM, yyyy"),
                        name: "duration",
                        validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: "Duration",
                            hintText: "Select Duration",
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: FormBuilderTextField(
                          name: "verifiedBy",
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                          decoration: const InputDecoration(
                              labelText: "Verified By",
                              hintText: "Enter Name",
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black))),
                    ),
                    if (!isEmpty)
                      Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )),
                              side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).primaryColor)),
                            ),
                            onPressed: () async {
                              if (_durationFormKey.currentState!.validate()) {
                                _durationFormKey.currentState!.save();

                                DateTimeRange duration =
                                    _durationFormKey.currentState!.value['duration'];

                                var start = duration.start.toUtc().toIso8601String();
                                var end = duration.end.toUtc().toIso8601String();

                                var verifiedBy = _durationFormKey.currentState!.value['verifiedBy'];
                                print("Verified By $verifiedBy");

                                await downloadPerformanceCard(start, end, verifiedBy);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              "Download",
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                  ],
                ),
              )),
        );
      },
    );
  }

  Future<void> downloadPerformanceCard(start, end, verifiedBy) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    try {
      var request = request_client.Request();
      final response = await request.post(Uri.parse("performance-card/download"), body: {
        "verifiedBy": verifiedBy,
        "startDate": start,
        "endDate": end,
      });

      if (response.statusCode == 201) {
        File f = File("$tempPath/PerformanceCard.csv");
        f.writeAsString(response.body);

        try {
          final params = SaveFileDialogParams(sourceFilePath: f.path);
          await FlutterFileDialog.saveFile(params: params);
          print(params.sourceFilePath);
          // ignore: use_build_context_synchronously
          showAlertDialog(context, 'Success', "Download success", isPop: false);
        } catch (e) {
          // ignore: use_build_context_synchronously
          showAlertDialog(
              context,
              'Error',
              "Unable to save your performance card. Make sure you have enabled permission to access storage!",
              isPop: false);
        }
      } else {
        // reasonPhrase is nullable; provide a fallback string
        final reason = response.reasonPhrase ?? 'Unknown error while downloading performance card';
        // ignore: use_build_context_synchronously
        showAlertDialog(context, 'Error', reason, isPop: false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showAlertDialog(
          context,
          'Error',
          "There was some internal server error while downloading your performance card. Please try again or contact support!",
          isPop: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return performanceCard != null
        ? Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text('My Performance Card ',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  // Spacer(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: performanceCard == null
                        ? null
                        : () {
                            getDownloadDates();
                          },
                    child: Text(
                      "Download",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(letterSpacing: 1.5, decoration: TextDecoration.underline),
                    ),
                  ),
                  // Spacer(),
                ],
              ),
              for (var cls in performanceCard!)
                Builder(builder: (_) {
                  final totalDistanceCovered = cls['totalDistanceCovered'] ?? 0;
                  return Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        width: MediaQuery.of(context).size.width * 1.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Class ${cls['licenseClass']['class']}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Wrap(
                              alignment: WrapAlignment.spaceAround,
                              children: <Widget>[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: totalDistanceCovered < 3000
                                            ? CircularPercentIndicator(
                                                radius: 45,
                                                percent: (totalDistanceCovered / 3000),
                                                progressColor: Colors.blue,
                                                center: Text(
                                                  "${(totalDistanceCovered / 3000 * 100).toStringAsFixed(2)}%",
                                                  style: const TextStyle(fontSize: 12.0),
                                                ),
                                              )
                                            : CircularPercentIndicator(
                                                radius: 45,
                                                percent: 1,
                                                progressColor: Colors.blue,
                                                center: const Text(
                                                  "100%",
                                                  style: TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                      ),
                                      const Text("3k Bonus"),
                                      totalDistanceCovered >= 3000
                                          ? const Text("Done!")
                                          : Text("${3000 - totalDistanceCovered}km Left!"),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: totalDistanceCovered < 6000
                                            ? CircularPercentIndicator(
                                                radius: 45,
                                                percent: (totalDistanceCovered / 6000),
                                                progressColor: Colors.blue,
                                                center: Text(
                                                  "${(totalDistanceCovered / 6000 * 100).toStringAsFixed(2)}%",
                                                  style: const TextStyle(fontSize: 12.0),
                                                ),
                                              )
                                            : CircularPercentIndicator(
                                                radius: 45,
                                                percent: 1,
                                                progressColor: Colors.blue,
                                                center: const Text(
                                                  "100%",
                                                  style: TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                      ),
                                      const Text("6k Bonus"),
                                      totalDistanceCovered >= 6000
                                          ? const Text("Done!")
                                          : Text("${6000 - totalDistanceCovered}km Left!"),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.25,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        child: totalDistanceCovered < 9000
                                            ? CircularPercentIndicator(
                                                radius: 45,
                                                percent: (totalDistanceCovered / 9000),
                                                progressColor: Colors.blue,
                                                center: Text(
                                                  "${(totalDistanceCovered / 9000 * 100).toStringAsFixed(2)}%",
                                                  style: const TextStyle(fontSize: 12.0),
                                                ),
                                              )
                                            : CircularPercentIndicator(
                                                radius: 45,
                                                percent: 1,
                                                progressColor: Colors.blue,
                                                center: const Text(
                                                  "100%",
                                                  style: TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                      ),
                                      const Text("9k Bonus"),
                                      totalDistanceCovered >= 9000
                                          ? const Text("Done!")
                                          : Text("${9000 - totalDistanceCovered}km Left!"),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          )
        : Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text('My Performance Card ',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  // Spacer(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: null,
                    child: Text(
                      "Download",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(letterSpacing: 1.5, decoration: TextDecoration.underline),
                    ),
                  ),
                  // Spacer(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: isEmpty
                    ? const Text(
                        "No completed trips are found!",
                        textAlign: TextAlign.center,
                      )
                    : const CircularProgressIndicator(),
              )
            ],
          );
  }
}
