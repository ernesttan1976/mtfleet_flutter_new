import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/constants.dart' as Constants;
import 'package:transport_flutter/screens/Driver/additionalDetail.dart';
import 'package:transport_flutter/screens/Driver/checkList.dart';
import 'package:transport_flutter/screens/Driver/driverCheckList.dart';
import 'package:transport_flutter/screens/Driver/mtrcForm.dart';
import 'package:transport_flutter/screens/Driver/quiz.dart';
import 'package:transport_flutter/screens/Driver/riskAccessment.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/quizArray.dart';

class TripPageView extends StatefulWidget {
  final bool mtrcApprovalRequired;
  final bool isVehicleCommander;

  TripPageView(this.mtrcApprovalRequired, this.isVehicleCommander, {Key? key}) : super(key: key);

  @override
  _TripPageViewState createState() => _TripPageViewState();
}

class _TripPageViewState extends State<TripPageView> {
  final pageViewController = PageController();
  final _client = AuthedDio.instance.dio;

  // TripForm Variable
  var tripFormData;

  // Quiz Screen Variables
  late List answers;
  List quizzes = [];

  // Additional Form Data
  var additionalDetailsFormData;

  // When Vehicle Commander the CheckList and Email Data
  var checkListFormData;
  var driverCheckListData;
  var vehicleCommanderChechListFormData;
  String overAllRisk = "LOW";
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 50,
      lineLength: 150,
    ),
  );

  // Trip Form Data Functions
  void setTripData(index, formDataObject) {
    print(formDataObject);
    if (formDataObject['vehicleDropDown'] == "Motorcycle") {
      if (widget.isVehicleCommander) {
        print("Vehicle Commander HA");
        setState(() {
          quizzes = motorcycleQuizArray;
          var rng = new Random();
          answers = new List.generate(quizzes.length, (_) => rng.nextInt(1));
        });
      } else {
        print("Vehicle Commander NHI HA");

        setState(() {
          quizzes = motorcycleQuizArrayWithOutCommander;
          var rng = new Random();
          answers = new List.generate(quizzes.length, (_) => rng.nextInt(1));
        });
      }
    } else {
      if (widget.isVehicleCommander) {
        print("Vehicle Commander HA");

        setState(() {
          quizzes = quizArray;
          var rng = new Random();
          answers = new List.generate(quizzes.length, (_) => rng.nextInt(1));
        });
      } else {
        print("Vehicle Commander NHI HA");

        setState(() {
          quizzes = quizArrayWithOutCommander;
          var rng = new Random();
          answers = new List.generate(quizzes.length, (_) => rng.nextInt(1));
        });
      }
    }

    setState(() {
      tripFormData = formDataObject;
    });
    print("Data: $tripFormData");

    pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  // Quiz Screens Functions
  void setQuizAnswer(index, answer) {
    setState(() {
      final newAnswers = answers;
      newAnswers[index] = answer;
      answers = newAnswers;
    });
    print("Answers: $answers");
  }

  void onNextQuiz(index) {
    pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onPrevQuiz(index) {
    pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onDriverNext(index, checklist) {
    var newCheckList = [];
    for (var i = 0; i < checklist['driver_checklist'].length; i++) {
      newCheckList.add({'title': "${checklist['driver_checklist'][i]}"});
    }
    setState(() {
      driverCheckListData = newCheckList;
    });
    print("Driver: $newCheckList");
    onNextQuiz(index);
  }

  void calculateRisk() {
    int low = 0;
    int medium = 0;
    int high = 0;
    int noMove = 0;
    print("Answers: $answers");

    if (tripFormData['vehicleDropDown'] == "Motorcycle") {
      if (widget.isVehicleCommander) {
        for (var i = 0; i < answers.length; i++) {
          var options = motorcycleQuizArray[i]['options'];
          for (var item in options) {
            var answer = answers[i].split("  ")[0];
            print(answer);
            if (item['content'] == answer) {
              if (item['correctAnswer'] == 'Low') {
                low = low + 1;
              } else if (item['correctAnswer'] == 'Medium') {
                medium = medium + 1;
              } else if (item['correctAnswer'] == 'High') {
                high = high + 1;
              } else {
                noMove = noMove + 1;
              }
              break;
            }
          }
        }
      } else {
        for (var i = 0; i < answers.length; i++) {
          var options = motorcycleQuizArrayWithOutCommander[i]['options'];
          for (var item in options) {
            var answer = answers[i].split("  ")[0];
            print(answer);
            if (item['content'] == answer) {
              if (item['correctAnswer'] == 'Low') {
                low = low + 1;
              } else if (item['correctAnswer'] == 'Medium') {
                medium = medium + 1;
              } else if (item['correctAnswer'] == 'High') {
                high = high + 1;
              } else {
                noMove = noMove + 1;
              }
              break;
            }
          }
        }
      }
    } else {
      if (widget.isVehicleCommander) {
        for (var i = 0; i < answers.length; i++) {
          var options = quizArray[i]['options'];
          for (var item in options) {
            var answer = answers[i].split("  ")[0];
            print(answer);
            if (item['content'] == answer) {
              if (item['correctAnswer'] == 'Low') {
                low = low + 1;
              } else if (item['correctAnswer'] == 'Medium') {
                medium = medium + 1;
              } else if (item['correctAnswer'] == 'High') {
                high = high + 1;
              } else {
                noMove = noMove + 1;
              }
              break;
            }
          }
        }
      } else {
        for (var i = 0; i < answers.length; i++) {
          var options = quizArrayWithOutCommander[i]['options'];
          for (var item in options) {
            var answer = answers[i].split("  ")[0];
            print(answer);
            if (item['content'] == answer) {
              if (item['correctAnswer'] == 'Low') {
                low = low + 1;
              } else if (item['correctAnswer'] == 'Medium') {
                medium = medium + 1;
              } else if (item['correctAnswer'] == 'High') {
                high = high + 1;
              } else {
                noMove = noMove + 1;
              }
              break;
            }
          }
        }
      }
    }

    List<int> mList = [low, medium, high, noMove];
    print("mLIST: $mList");
    // int maxNumber = mList.reduce((curr, next) => curr > next ? curr : next);
    if (mList[2] > 0) {
      setState(() {
        overAllRisk = "HIGH";
      });
    } else if (mList[1] > 0) {
      setState(() {
        overAllRisk = "MEDIUM";
      });
    } else {
      setState(() {
        overAllRisk = "LOW";
      });
    }
  }

  // Additional Form Details Functions
  void setAdditionalFormData(index, formDataObject) {
    calculateRisk();
    print("Index");
    setState(() {
      additionalDetailsFormData = formDataObject;
    });
    print("Data: $additionalDetailsFormData");
    pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onSubmitCheckListForm(formDataObject) {
    setState(() {
      checkListFormData = formDataObject;
    });
    vehicleCommanderFormSubmission();
  }

  // Vehicle Commander  Form Data Functions
  void onSubmitVehicleCommanderForm(formDataObject) {
    setState(() {
      vehicleCommanderChechListFormData = formDataObject;
    });
    print("Data: $vehicleCommanderChechListFormData");
  }

  // Full Form Submission Functions

  void submitMTRACFormWithNoVehicleCommander(driverChecklist) async {
    try {
      String? token = await storage.read(key: Constants.storageBearer);
      logger.e("Form Submit | Vehicle Commander $token");
      var currentRole = await getCurrentRole();
      var rng = new Random();
      List myQuizzes = new List.generate(quizzes.length, (_) => rng.nextInt(1));

      // Quizzes Array Formation
      for (var i = 0; i < quizzes.length; i++) {
        String title = quizzes[i]['title'];
        String answer = answers[i];
        myQuizzes[i] = {"question": title, "answer": answer};
      }

      var mtracForm = Map.of(additionalDetailsFormData);
      mtracForm['isAdditionalDetailsApplicable'] =
          mtracForm['isAdditionalDetailsApplicable'] == null ? false : mtracForm['isAdditionalDetailsApplicable'];
      mtracForm['quizzes'] = myQuizzes;
      mtracForm['overAllRisk'] = overAllRisk;
      //
      // if (checkListFormData['filledBy'] == "Front Passenger") {
      //   var new_checkList = [];
      //   for (var i = 0;
      //       i < checkListFormData['passenger_checklist'].length;
      //       i++) {
      //     new_checkList
      //         .add({'title': "${checkListFormData['passenger_checklist'][i]}"});
      //   }
      //   mtracForm['otherRiskAssessmentChecklist'] = new_checkList;
      //   mtracForm["rankAndName"] = checkListFormData['rankAndName'];
      //   mtracForm["personalPin"] = checkListFormData['personalPin'];
      //   mtracForm["filledBy"] = "FrontPassenger";
      // } else {
      //   var new_checkList = [];
      //   for (var i = 0;
      //       i < checkListFormData['commander_checklist'].length;
      //       i++) {
      //     new_checkList
      //         .add({'title': "${checkListFormData['commander_checklist'][i]}"});
      //   }
      //   mtracForm['otherRiskAssessmentChecklist'] = new_checkList;
      //   mtracForm["rankAndName"] = checkListFormData['rankAndName'];
      //   mtracForm["personalPin"] = checkListFormData['personalPin'];
      //   mtracForm["filledBy"] = "VehicleCommander";
      // }
      mtracForm['driverRiskAssessmentChecklist'] = driverCheckListData;
      tripFormData['aviDate'] = mtracForm['aviDate'];
      tripFormData['MTRACForm'] = mtracForm;

      final _map = {
        "tripDate": tripFormData['tripDate'].toUtc().toIso8601String(),
        // TODO : get dateTime now
        "endedAt": DateTime.now().toUtc().toIso8601String(),

        "vehicle": int.parse(tripFormData['vehicle']),
        "aviDate": mtracForm['aviDate'].toUtc().toIso8601String(),
        // TODO : đang lấy mặc định
        "currentMeterReading": 22, //
        "isTripFromPreApprovedDriver": currentRole != 'DRIVER', //
        "approvingOfficer": int.parse(tripFormData['approvingOfficer'].toString()),
        "destinations": (tripFormData['destinations'] as List)
            .map((e) => {"to": e['to'], "requisitionerPurpose": e['requisitionerPurpose']})
            .toList(),
      };

      final _mtracForm = {
        "overAllRisk": mtracForm['overAllRisk'],
        "isAdditionalDetailApplicable": !mtracForm['isAdditionalDetailsApplicable'],
        "safetyMeasures": "string",
        // "rankAndName": mtracForm["rankAndName"],
        // "personalPin": mtracForm["personalPin"],
        // "filledBy": mtracForm["filledBy"],
        // "otherRiskAssessmentChecklist":
        //     (mtracForm['otherRiskAssessmentChecklist'] as List)
        //         .map((e) => e['title'])
        //         .toList(),
        "driverRiskAssessmentChecklist":
            (mtracForm['driverRiskAssessmentChecklist'] as List).map((e) => e['title']).toList(),
        "quizzes": mtracForm['quizzes']
      };

      var today = new DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (!mtracForm['isAdditionalDetailsApplicable']) {
        _mtracForm.addAll({
          "dispatchDate": mtracForm['despatchDate'].toUtc().toIso8601String(),
          "dispatchTime":
              mtracForm['despatchTime'].toUtc().toIso8601String().toString().replaceAll('0001-01-01', today.toString()),
          "releaseDate": mtracForm['releaseDate'].toUtc().toIso8601String(),
          "releaseTime":
              mtracForm['releaseTime'].toUtc().toIso8601String().toString().replaceAll('0001-01-01', today.toString()),
        });
      }

      _map.addAll({'MTRACForm': _mtracForm});

      var dataJSON = jsonEncode(_map, toEncodable: myEncode);
      logger.e(dataJSON);
      final _dio = await _client;
      var response = await _dio.post("/trips/mtrac-form", data: dataJSON);

      print(response.data);
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", "Trip approval form is sent successfully!", isPop: false, callBack: () {
          Navigator.of(context).popAndPushNamed('/driver');
        });
      } else {
        showAlertDialog(context, "Error", response.data['message'], isPop: false);
      }
    } on DioException catch (e) {
      logger.e(" Catch Error ${e.response?.data}");
      showAlertDialog(context, "Error", e.response!.data["message"]);
    }
  }

  void submitMTRACFormWithNoVechileCommanderAndDriverChecklist(formDataObject) {
    print("Driver Check List DATA!: $formDataObject");
    var newCheckList = [];
    for (var i = 0; i < formDataObject['driver_checklist'].length; i++) {
      newCheckList.add({'title': "${formDataObject['driver_checklist'][i]}"});
    }
    setState(() {
      driverCheckListData = newCheckList;
    });
    submitMTRACFormWithNoVehicleCommander(newCheckList);
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  void vehicleCommanderFormSubmission() async {
    try {
      String? token = await storage.read(key: Constants.storageBearer);
      print("Form Submit | Vehicle Commander $token");
      var rng = new Random();
      var currentRole = await getCurrentRole();
      List myQuizzes = new List.generate(quizzes.length, (_) => rng.nextInt(1));

      // Quizzes Array Formation
      for (var i = 0; i < quizzes.length; i++) {
        String title = quizzes[i]['title'];
        String answer = answers[i];
        myQuizzes[i] = {"question": title, "answer": answer};
      }

      var mtracForm = Map.of(additionalDetailsFormData);
      mtracForm['isAdditionalDetailsApplicable'] =
          mtracForm['isAdditionalDetailsApplicable'] == null ? false : mtracForm['isAdditionalDetailsApplicable'];
      mtracForm['quizzes'] = myQuizzes;
      mtracForm['overAllRisk'] = overAllRisk;

      if (checkListFormData['filledBy'] == "Front Passenger") {
        var newCheckList = [];
        for (var i = 0; i < checkListFormData['passenger_checklist'].length; i++) {
          newCheckList.add({'title': "${checkListFormData['passenger_checklist'][i]}"});
        }
        mtracForm['otherRiskAssessmentChecklist'] = newCheckList;
        mtracForm["rankAndName"] = checkListFormData['rankAndName'];
        mtracForm["personalPin"] = checkListFormData['personalPin'];
        mtracForm["filledBy"] = "FrontPassenger";
      } else {
        var newCheckList = [];
        for (var i = 0; i < checkListFormData['commander_checklist'].length; i++) {
          newCheckList.add({'title': "${checkListFormData['commander_checklist'][i]}"});
        }
        mtracForm['otherRiskAssessmentChecklist'] = newCheckList;
        mtracForm["rankAndName"] = checkListFormData['rankAndName'];
        mtracForm["personalPin"] = checkListFormData['personalPin'];
        mtracForm["filledBy"] = "VehicleCommander";
      }
      mtracForm['driverRiskAssessmentChecklist'] = driverCheckListData;
      tripFormData['aviDate'] = mtracForm['aviDate'];
      tripFormData['MTRACForm'] = mtracForm;

      final _map = {
        "tripDate": tripFormData['tripDate'].toUtc().toIso8601String(),
        // TODO : get dateTime now
        "endedAt": DateTime.now().toUtc().toIso8601String(),

        "vehicle": int.parse(tripFormData['vehicle']),
        "aviDate": mtracForm['aviDate'].toUtc().toIso8601String(),
        // TODO : đang lấy mặc định
        "currentMeterReading": 22, //
        "isTripFromPreApprovedDriver": currentRole != 'DRIVER', //
        "approvingOfficer": int.parse(tripFormData['approvingOfficer'].toString()),
        "destinations": (tripFormData['destinations'] as List)
            .map((e) => {"to": e['to'], "requisitionerPurpose": e['requisitionerPurpose']})
            .toList(),
      };

      final _mtracForm = {
        "overAllRisk": mtracForm['overAllRisk'],
        "isAdditionalDetailApplicable": !mtracForm['isAdditionalDetailsApplicable'],
        "safetyMeasures": "string",
        "rankAndName": mtracForm["rankAndName"],
        "personalPin": mtracForm["personalPin"],
        "filledBy": mtracForm["filledBy"],
        "otherRiskAssessmentChecklist":
            (mtracForm['otherRiskAssessmentChecklist'] as List).map((e) => e['title']).toList(),
        "driverRiskAssessmentChecklist":
            (mtracForm['driverRiskAssessmentChecklist'] as List).map((e) => e['title']).toList(),
        "quizzes": mtracForm['quizzes']
      };

      if (!mtracForm['isAdditionalDetailsApplicable']) {
        var today = new DateFormat('yyyy-MM-dd').format(DateTime.now());
        _mtracForm.addAll({
          "dispatchDate": mtracForm['despatchDate'].toUtc().toIso8601String(),
          "dispatchTime":
              mtracForm['despatchTime'].toUtc().toIso8601String().toString().replaceAll('0001-01-01', today.toString()),
          "releaseDate": mtracForm['releaseDate'].toUtc().toIso8601String(),
          "releaseTime":
              mtracForm['releaseTime'].toUtc().toIso8601String().toString().replaceAll('0001-01-01', today.toString()),
        });
      }

      _map.addAll({'MTRACForm': _mtracForm});
      var dataJSON = jsonEncode(_map, toEncodable: myEncode);
      debugPrint(dataJSON, wrapWidth: 1024);
      final _dio = await _client;
      var response = await _dio.post("/trips/mtrac-form", data: dataJSON);

      logger.e(response.data);
      if (response.statusCode == 201) {
        showAlertDialog(context, "Success", "Trip approval form is sent successfully!", isPop: false, callBack: () {
          Navigator.of(context).popAndPushNamed('/driver');
        });
      } else if (response.statusCode == 500) {
        showAlertDialog(context, "Server Error", response.data);
      } else {
        showAlertDialog(context, "Error", response.data['message'], isPop: false);
      }
    } on DioException catch (e) {
      showAlertDialog(
        context,
        "Error Catch",
        "${e.response!.data["status"]} ${e.response!.data["message"]}",
        isPop: false,
      );
    }
  }

  @override
  void initState() {
    quizzes = quizArray;
    var rng = new Random();
    answers = new List.generate(quizzes.length, (_) => rng.nextInt(1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: new NeverScrollableScrollPhysics(),
        controller: pageViewController,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return MTRCFormScreen(true, true, setTripData);
          }
          if (index - 1 < quizzes.length) {
            return QuizScreen(
              setSelection: setQuizAnswer,
              index: index - 1,
              onNext: onNextQuiz,
              quiz: quizzes[index - 1],
              totalQuiz: quizzes.length,
              selectedAnswer: answers[index - 1],
              onPrev: onPrevQuiz,
            );
          } else if (index == quizzes.length + 1) {
            return AdditionalDetailScreen(
              onNext: setAdditionalFormData,
              onPrev: onPrevQuiz,
              index: index,
            );
          } else if (index == quizzes.length + 2) {
            return RiskAccessmentScreen(
              onNext: onNextQuiz,
              onPrev: onPrevQuiz,
              index: index,
              isVehicleCommander: widget.isVehicleCommander,
              overAllRisk: overAllRisk,
            );
          } else if (index == quizzes.length + 3) {
            return DriverCheckList(
              onPrev: onPrevQuiz,
              onNext: onDriverNext,
              index: index,
              overAllRisk: overAllRisk,
              isVehicleCommander: widget.isVehicleCommander,
              onSubmit: submitMTRACFormWithNoVechileCommanderAndDriverChecklist,
            );
          } else if (index == quizzes.length + 4) {
            return CheckListScreen(
              onPrev: onPrevQuiz,
              index: index,
              onSubmit: onSubmitCheckListForm,
              overAllRisk: overAllRisk,
            );
          } else {
            return Text("Nothing");
          }
        },
        itemCount: 1 + quizzes.length + 4,
      ),
    );
  }
}
