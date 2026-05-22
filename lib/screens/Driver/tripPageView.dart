import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/constants.dart' as constants;
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

  const TripPageView(this.mtrcApprovalRequired, this.isVehicleCommander, {Key? key}) : super(key: key);

  @override
  State<TripPageView> createState() => _TripPageViewState();
}

class _TripPageViewState extends State<TripPageView> {
  final pageViewController = PageController();
  final _client = AuthedDio.instance.dio;

  // TripForm Variable
  Map<String, dynamic>? tripFormData;

  // Quiz Screen Variables
  late List<String> answers;
  List<Map<String, dynamic>> quizzes = [];

  // Additional Form Data
  Map<String, dynamic>? additionalDetailsFormData;

  // When Vehicle Commander the CheckList and Email Data
  Map<String, dynamic>? checkListFormData;
  List<Map<String, dynamic>>? driverCheckListData;
  Map<String, dynamic>? vehicleCommanderChechListFormData;
  String overAllRisk = "LOW";
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 50,
      lineLength: 150,
    ),
  );

  // Trip Form Data Functions
  void setTripData(int index, Map<String, dynamic> formDataObject) {
    print(formDataObject);
    if (formDataObject['vehicleDropDown'] == "Motorcycle") {
      if (widget.isVehicleCommander) {
        print("Vehicle Commander HA");
        setState(() {
          quizzes = List<Map<String, dynamic>>.from(motorcycleQuizArray);
          var rng = Random();
          answers = List<String>.generate(quizzes.length, (_) => rng.nextInt(1).toString());
        });
      } else {
        print("Vehicle Commander NHI HA");

        setState(() {
          quizzes = List<Map<String, dynamic>>.from(motorcycleQuizArrayWithOutCommander);
          var rng = Random();
          answers = List<String>.generate(quizzes.length, (_) => rng.nextInt(1).toString());
        });
      }
    } else {
      if (widget.isVehicleCommander) {
        print("Vehicle Commander HA");

        setState(() {
          quizzes = List<Map<String, dynamic>>.from(quizArray);
          var rng = Random();
          answers = List<String>.generate(quizzes.length, (_) => rng.nextInt(1).toString());
        });
      } else {
        print("Vehicle Commander NHI HA");

        setState(() {
          quizzes = List<Map<String, dynamic>>.from(quizArrayWithOutCommander);
          var rng = Random();
          answers = List<String>.generate(quizzes.length, (_) => rng.nextInt(1).toString());
        });
      }
    }

    setState(() {
      tripFormData = Map<String, dynamic>.from(formDataObject);
    });
    print("Data: $tripFormData");

    pageViewController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  // Quiz Screens Functions
  void setQuizAnswer(int index, String answer) {
    setState(() {
      final newAnswers = List<String>.from(answers);
      newAnswers[index] = answer;
      answers = newAnswers;
    });
    print("Answers: $answers");
  }

  void onNextQuiz(int index) {
    pageViewController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onPrevQuiz(int index) {
    pageViewController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onDriverNext(int index, Map<String, dynamic> checklist) {
    var newCheckList = <Map<String, String>>[];
    for (var i = 0; i < checklist['driver_checklist'].length; i++) {
      newCheckList.add({'title': "${checklist['driver_checklist'][i]}"});
    }
    setState(() {
      driverCheckListData = List<Map<String, dynamic>>.from(newCheckList);
    });
    print("Driver: $newCheckList");
    onNextQuiz(index);
  }

  void calculateRisk() {
    var low = 0;
    var medium = 0;
    var high = 0;
    var noMove = 0;
    print("Answers: $answers");

    if (tripFormData?['vehicleDropDown'] == "Motorcycle") {
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

    var mList = [low, medium, high, noMove];
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
  void setAdditionalFormData(int index, Map<String, dynamic> formDataObject) {
    calculateRisk();
    print("Index");
    setState(() {
      additionalDetailsFormData = Map<String, dynamic>.from(formDataObject);
    });
    print("Data: $additionalDetailsFormData");
    pageViewController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void onSubmitCheckListForm(Map<String, dynamic> formDataObject) {
    setState(() {
      checkListFormData = Map<String, dynamic>.from(formDataObject);
    });
    vehicleCommanderFormSubmission();
  }

  // Vehicle Commander  Form Data Functions
  void onSubmitVehicleCommanderForm(Map<String, dynamic> formDataObject) {
    setState(() {
      vehicleCommanderChechListFormData = Map<String, dynamic>.from(formDataObject);
    });
    print("Data: $vehicleCommanderChechListFormData");
  }

  // Full Form Submission Functions

  void submitMTRACFormWithNoVehicleCommander(List<Map<String, dynamic>> driverChecklist) async {
    try {
      String? token = await storage.read(key: constants.storageBearer);
      logger.e("Form Submit | Vehicle Commander $token");
      var currentRole = await getCurrentRole();
      List<Map<String, dynamic>> myQuizzes =
          List<Map<String, dynamic>>.generate(quizzes.length, (_) => {'question': '', 'answer': ''});

      // Quizzes Array Formation
      for (var i = 0; i < quizzes.length; i++) {
        String title = quizzes[i]['title'];
        String answer = answers[i];
        myQuizzes[i] = {"question": title, "answer": answer};
      }

      var mtracForm = Map<String, dynamic>.from(additionalDetailsFormData ?? {});
      mtracForm['isAdditionalDetailsApplicable'] = mtracForm['isAdditionalDetailsApplicable'] ?? false;
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
      tripFormData?['aviDate'] = mtracForm['aviDate'];
      tripFormData?['MTRACForm'] = mtracForm;

      final map = {
        "tripDate": (tripFormData?['tripDate'] as DateTime).toUtc().toIso8601String(),
        // TODO : get dateTime now
        "endedAt": DateTime.now().toUtc().toIso8601String(),

        "vehicle": int.parse(tripFormData?['vehicle'] as String),
        "aviDate": (mtracForm['aviDate'] as DateTime).toUtc().toIso8601String(),
        // TODO : đang lấy mặc định
        "currentMeterReading": 22, //
        "isTripFromPreApprovedDriver": currentRole != 'DRIVER', //
        "approvingOfficer": int.parse(tripFormData?['approvingOfficer'] as String),
        "destinations": (tripFormData?['destinations'] as List)
            .map((e) => {"to": e['to'], "requisitionerPurpose": e['requisitionerPurpose']})
            .toList(),
      };

      final mtracFormPayload = {
        "overAllRisk": mtracForm['overAllRisk'],
        "isAdditionalDetailApplicable": !(mtracForm['isAdditionalDetailsApplicable'] as bool),
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

      var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (!(mtracForm['isAdditionalDetailsApplicable'] as bool)) {
        mtracFormPayload.addAll({
          "dispatchDate": (mtracForm['despatchDate'] as DateTime).toUtc().toIso8601String(),
          "dispatchTime": (mtracForm['despatchTime'] as DateTime)
              .toUtc()
              .toIso8601String()
              .toString()
              .replaceAll('0001-01-01', today.toString()),
          "releaseDate": (mtracForm['releaseDate'] as DateTime).toUtc().toIso8601String(),
          "releaseTime": (mtracForm['releaseTime'] as DateTime)
              .toUtc()
              .toIso8601String()
              .toString()
              .replaceAll('0001-01-01', today.toString()),
        });
      }

      map.addAll({'MTRACForm': mtracFormPayload});

      var dataJSON = jsonEncode(map, toEncodable: myEncode);
      logger.e(dataJSON);
      final dio = await _client;
      var response = await dio.post("/trips/mtrac-form", data: dataJSON);

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

  void submitMTRACFormWithNoVechileCommanderAndDriverChecklist(Map<String, dynamic> formDataObject) {
    print("Driver Check List DATA!: $formDataObject");
    var newCheckList = <Map<String, String>>[];
    for (var i = 0; i < formDataObject['driver_checklist'].length; i++) {
      newCheckList.add({'title': "${formDataObject['driver_checklist'][i]}"});
    }
    setState(() {
      driverCheckListData = List<Map<String, dynamic>>.from(newCheckList);
    });
    submitMTRACFormWithNoVehicleCommander(List<Map<String, dynamic>>.from(newCheckList));
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toString();
    }
    return item;
  }

  void vehicleCommanderFormSubmission() async {
    try {
      String? token = await storage.read(key: constants.storageBearer);
      print("Form Submit | Vehicle Commander $token");
      var currentRole = await getCurrentRole();
      List<Map<String, dynamic>> myQuizzes =
          List<Map<String, dynamic>>.generate(quizzes.length, (_) => {'question': '', 'answer': ''});

      // Quizzes Array Formation
      for (var i = 0; i < quizzes.length; i++) {
        String title = quizzes[i]['title'];
        String answer = answers[i];
        myQuizzes[i] = {"question": title, "answer": answer};
      }

      var mtracForm = Map<String, dynamic>.from(additionalDetailsFormData ?? {});
      mtracForm['isAdditionalDetailsApplicable'] = mtracForm['isAdditionalDetailsApplicable'] ?? false;
      mtracForm['quizzes'] = myQuizzes;
      mtracForm['overAllRisk'] = overAllRisk;

      if (checkListFormData?['filledBy'] == "Front Passenger") {
        var newCheckList = <Map<String, String>>[];
        for (var i = 0; i < (checkListFormData?['passenger_checklist'] as List).length; i++) {
          newCheckList.add({'title': "${checkListFormData?['passenger_checklist'][i]}"});
        }
        mtracForm['otherRiskAssessmentChecklist'] = newCheckList;
        mtracForm["rankAndName"] = checkListFormData?['rankAndName'];
        mtracForm["personalPin"] = checkListFormData?['personalPin'];
        mtracForm["filledBy"] = "FrontPassenger";
      } else {
        var newCheckList = <Map<String, String>>[];
        for (var i = 0; i < (checkListFormData?['commander_checklist'] as List).length; i++) {
          newCheckList.add({'title': "${checkListFormData?['commander_checklist'][i]}"});
        }
        mtracForm['otherRiskAssessmentChecklist'] = newCheckList;
        mtracForm["rankAndName"] = checkListFormData?['rankAndName'];
        mtracForm["personalPin"] = checkListFormData?['personalPin'];
        mtracForm["filledBy"] = "VehicleCommander";
      }
      mtracForm['driverRiskAssessmentChecklist'] = driverCheckListData;
      tripFormData?['aviDate'] = mtracForm['aviDate'];
      tripFormData?['MTRACForm'] = mtracForm;

      final map = {
        "tripDate": (tripFormData?['tripDate'] as DateTime).toUtc().toIso8601String(),
        // TODO : get dateTime now
        "endedAt": DateTime.now().toUtc().toIso8601String(),

        "vehicle": int.parse(tripFormData?['vehicle'] as String),
        "aviDate": (mtracForm['aviDate'] as DateTime).toUtc().toIso8601String(),
        // TODO : đang lấy mặc định
        "currentMeterReading": 22, //
        "isTripFromPreApprovedDriver": currentRole != 'DRIVER', //
        "approvingOfficer": int.parse(tripFormData?['approvingOfficer'] as String),
        "destinations": (tripFormData?['destinations'] as List)
            .map((e) => {"to": e['to'], "requisitionerPurpose": e['requisitionerPurpose']})
            .toList(),
      };

      final mtracFormPayload = {
        "overAllRisk": mtracForm['overAllRisk'],
        "isAdditionalDetailApplicable": !(mtracForm['isAdditionalDetailsApplicable'] as bool),
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

      if (!(mtracForm['isAdditionalDetailsApplicable'] as bool)) {
        var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        mtracFormPayload.addAll({
          "dispatchDate": (mtracForm['despatchDate'] as DateTime).toUtc().toIso8601String(),
          "dispatchTime": (mtracForm['despatchTime'] as DateTime)
              .toUtc()
              .toIso8601String()
              .toString()
              .replaceAll('0001-01-01', today.toString()),
          "releaseDate": (mtracForm['releaseDate'] as DateTime).toUtc().toIso8601String(),
          "releaseTime": (mtracForm['releaseTime'] as DateTime)
              .toUtc()
              .toIso8601String()
              .toString()
              .replaceAll('0001-01-01', today.toString()),
        });
      }

      map.addAll({'MTRACForm': mtracFormPayload});
      var dataJSON = jsonEncode(map, toEncodable: myEncode);
      debugPrint(dataJSON, wrapWidth: 1024);
      final dio = await _client;
      var response = await dio.post("/trips/mtrac-form", data: dataJSON);

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
    super.initState();
    quizzes = List<Map<String, dynamic>>.from(quizArray);
    var rng = Random();
    answers = List<String>.generate(quizzes.length, (_) => rng.nextInt(1).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
            return const Text("Nothing");
          }
        },
        itemCount: 1 + quizzes.length + 4,
      ),
    );
  }
}
