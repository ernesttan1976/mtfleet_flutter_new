import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/util/request.dart' as request;

class Past14DaysELogBloc {
  final request = request.Request();

  final currentIndexTable = BehaviorSubject<int>();

  final isLoading = BehaviorSubject<bool>();

  final listELogVehicle = BehaviorSubject<List<ELogVehicleModel>>();

  final listELogBAPVehicle = BehaviorSubject<List<ELogBapVehicleModel>>();

  late int vehicleID;

  DateTime dateSelect = DateTime.now();

  void dispose() {
    currentIndexTable.close();
    isLoading.close();
    listELogVehicle.close();
    listELogBAPVehicle.close();
  }

  void onTapItem(ELogVehicleModel model) {}

  void onTapBAPItem(ELogBapVehicleModel model) {}

  Future fetchDataNormalAdHoc(BuildContext context) async {
    isLoading.add(true);
    try {
      final response = await request.get(Uri.parse("eLogs/vehicle?vehicleId=$vehicleID"));
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List).map((e) => ELogVehicleModel.fromJson(e)).toList();
        listELogVehicle.add(list);
      }
    } on HttpException catch (e) {
      showAlertDialog(context, "Error HttpException", e.message, isPop: false);
    } catch (e) {
      showAlertDialog(context, 'Error Catch', e.toString(), isPop: false);
    }
    isLoading.add(false);
  }

  Future fetchDataBAPH(BuildContext context) async {
    isLoading.add(true);
    try {
      final response = await request.get(Uri.parse("eLogs/bos-aos-pol/vehicle?vehicleId=$vehicleID"));
      if (response.statusCode == 200) {
        final list = (json.decode(response.body) as List).map((e) => ELogBapVehicleModel.fromJson(e)).toList();
        listELogBAPVehicle.add(list);
      }
    } on HttpException catch (e) {
      showAlertDialog(context, 'Error HttpException', e.message, isPop: false);
    } on Exception catch (e) {
      showAlertDialog(context, 'Error Catch', e.toString(), isPop: false);
    }
    isLoading.add(false);
  }
}
