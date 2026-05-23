import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/models/models.dart';
import 'package:transport_flutter/models/mt_broadcast.dart';
import 'package:transport_flutter/util/request.dart' as request;

class MTBroadCastBloc {
  final _dio = Dio();

  final percentDownLoad = BehaviorSubject<int>();

  final isLoading = BehaviorSubject<bool>();

  final listBroadCast = BehaviorSubject<List<MtBroadcastModel>>();

  final requestClient = Request.Request();

  void dispose() {
    percentDownLoad.close();
    isLoading.close();
    listBroadCast.close();
  }

  void loadAllBoardCast(BuildContext context) async {
    isLoading.add(true);
    try {
      final res = await request.get(Uri.parse('mt-broadcast'));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final _list = (json.decode(res.body) as List).map((e) => MtBroadcastModel.fromJson(e)).toList();
        listBroadCast.add(_list);
      } else {
        showAlertDialog(context, 'Error', res.reasonPhrase);
      }
    } catch (e) {
      showAlertDialog(context, 'Error', e.toString());
    }
    isLoading.add(false);
  }

  void downLoadBroadCats(BuildContext context, String url) async {
    isLoading.add(true);
    bool downloadInProgress = true;
    print(url);
    try {
      await Permission.storage.request();
      String localPath = '';
      if (Platform.isAndroid) {
        final downloadDirectory = await getApplicationDocumentsDirectory();
        localPath = downloadDirectory.path;
      } else {
        final downloadsDirectory = await getApplicationDocumentsDirectory();
        localPath = downloadsDirectory.path + Platform.pathSeparator + 'Download';
      }
      final savePath =
          localPath + '/${DateTime.now().millisecondsSinceEpoch}${url.substring(url.lastIndexOf("/") + 1)}';
      print(savePath);
      await _dio.download(url, savePath, onReceiveProgress: (rec, total) {
        final _percent = ((rec / total) * 100).round();
        percentDownLoad.add(_percent);
        if (_percent == 100 && downloadInProgress) {
          downloadInProgress = false;
          showAlertDialog(context, 'Download', 'File downloaded successfully', isPop: false);
        }
      });
    } catch (e) {
      showAlertDialog(context, 'Download Error', e.toString(), isPop: false);
    }
    percentDownLoad.add(0);
    downloadInProgress = false;
    isLoading.add(false);
  }
}
