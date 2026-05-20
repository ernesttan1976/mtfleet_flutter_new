import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as DioClient;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/constants.dart' as Constants;
import 'package:transport_flutter/screens/login.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as Request;
import 'package:webview_flutter/webview_flutter.dart';

class LoginAuthScreen extends StatefulWidget {
  @override
  _LoginAuthScreenState createState() => _LoginAuthScreenState();
}

class _LoginAuthScreenState extends State<LoginAuthScreen> {
  final _storage = FlutterSecureStorage();
  final dio = DioClient.Dio();
  final logger = Logger();
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final String loginUrl = '${Constants.SERVER_URI_API}/auth/microsoft/login';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            if (mounted) {
              if (url.startsWith(Constants.AUTH_CALLBACK)) {
                try {
                  var token = url.split("access_token=")[1];
                  await _storage.write(key: Constants.storageBearer, value: token);
                  var request = Request.Request();
                  var data = json.decode((await request.get(Uri.parse("users/me"))).body);
                  logger.e("loginData-> $data");
                  final _roles = <String>[];
                  (data['roles'] as List).forEach((element) {
                    if (SUPPORTED_ROLES.contains(element)) {
                      _roles.add(element);
                    }
                  });
                  if (_roles.isNotEmpty) {
                    var currentRole = _roles.first;
                    var authData = {
                      "user": {...data, "otherRoles": []}
                    };
                    await _storage.write(key: "auth", value: json.encode(authData));
                    await _storage.write(key: "currentRole", value: currentRole);
                    if (_roles.contains("APPROVING_OFFICER")) {
                      _setFirebaseToken(data);
                    } else {
                      _deleteFirebaseToken(data);
                    }

                    Navigator.pushReplacementNamed(context, '/appLoading');
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  error:
                                      "You don't have a proper role to access the application. Please contact the administration.",
                                )));
                  }
                } catch (e, trace) {
                  logger.e("Error In Login $e $trace");
                  await Sentry.captureException(e, stackTrace: trace);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                error: "There was some internal error while logging you in. Please try again!",
                              )));
                }
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(loginUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In Using Microsoft"),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  void _setFirebaseToken(dynamic data) async {
    try {
      final _client = AuthedDio.instance.dio;
      final _dio = await _client;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      try {
        messaging.subscribeToTopic("User-${data["id"]}");
      } catch (e) {
        logger.e("SubScribeToTopic $e");
      }
      final token = await messaging.getToken();
      var dataJSON = jsonEncode({"token": token});
      var response = await _dio.post("/users/me/fcm/subscribe", data: dataJSON);
      logger.e("Firebase Token $response");

      if (response.statusCode == 201) {
      } else {
        showAlertDialog(context, "Error", response.data['message'], isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, "Error", e);
    }
  }

  void _deleteFirebaseToken(dynamic data) async {
    try {
      final _client = AuthedDio.instance.dio;
      final _dio = await _client;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      try {
        messaging.unsubscribeFromTopic("User-${data["id"]}");
      } catch (e) {
        logger.e("unsubscribeFromTopic $e");
      }
      final token = await messaging.getToken();
      var dataJSON = jsonEncode({"token": token});
      await _dio.post("/users/me/fcm/unsubscribe", data: dataJSON);
      await messaging.deleteToken();
    } catch (e) {
      showAlertDialog(context, "Error", e, isPop: false);
    }
  }
}
