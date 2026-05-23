import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio_client;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transport_flutter/components/AlertDialog.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/constants.dart' as constants;
import 'package:transport_flutter/screens/login.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart' as request;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class LoginAuthScreen extends StatefulWidget {
  const LoginAuthScreen({Key? key}) : super(key: key);

  @override
  State<LoginAuthScreen> createState() => _LoginAuthScreenState();
}

class _LoginAuthScreenState extends State<LoginAuthScreen> {
  final _storage = FlutterSecureStorage();
  final dio = dio_client.Dio();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    //demo_transport3@swiftoffice.org
    //b2jr2ngb2l!

    // Enable virtual display.
    if (Platform.isAndroid) {
      final PlatformWebViewControllerCreationParams params =
          AndroidWebViewControllerCreationParams();
      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      WebViewWidget(controller: controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = '${constants.SERVER_URI_API}/auth/microsoft/login';
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In Using Microsoft"),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(loginUrl))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                if (mounted) {
                  if (url.startsWith(constants.AUTH_CALLBACK)) {
                    try {
                      var token = url.split("access_token=")[1];
                      await _storage.write(key: constants.storageBearer, value: token);
                      var httpRequest = request.Request();
                      var data = json.decode((await httpRequest.get(Uri.parse("users/me"))).body);
                      logger.e("loginData-> $data");
                      final roles = <String>[];
                      for (final role in (data['roles'] as List)) {
                        if (SUPPORTED_ROLES.contains(role)) {
                          roles.add(role);
                        }
                      }
                      if (roles.isNotEmpty) {
                        var currentRole = roles.first;
                        var authData = {
                          "user": {...data, "otherRoles": []}
                        };
                        await _storage.write(key: "auth", value: json.encode(authData));
                        await _storage.write(key: "currentRole", value: currentRole);
                        if (roles.contains("APPROVING_OFFICER")) {
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
                            ),
                          ),
                        );
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
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
      ),
    );
  }

  void _setFirebaseToken(dynamic data) async {
    try {
      final client = AuthedDio.instance.dio;
      final dioClient = await client;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      try {
        messaging.subscribeToTopic("User-${data["id"]}");
      } catch (e) {
        logger.e("SubScribeToTopic $e");
      }
      final token = await messaging.getToken();
      var dataJSON = jsonEncode({"token": token});
      var response = await dioClient.post("/users/me/fcm/subscribe", data: dataJSON);
      logger.e("Firebase Token $response");

      if (response.statusCode == 201) {
      } else {
        showAlertDialog(context, "Error", response.data['message'], isPop: false);
      }
    } catch (e) {
      showAlertDialog(context, "Error", e.toString());
    }
  }

  void _deleteFirebaseToken(dynamic data) async {
    try {
      final client = AuthedDio.instance.dio;
      final dioClient = await client;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      try {
        messaging.unsubscribeFromTopic("User-${data["id"]}");
      } catch (e) {
        logger.e("unsubscribeFromTopic $e");
      }
      final token = await messaging.getToken();
      var dataJSON = jsonEncode({"token": token});
      await dioClient.post("/users/me/fcm/unsubscribe", data: dataJSON);
      await messaging.deleteToken();
    } catch (e) {
      showAlertDialog(context, "Error", e.toString(), isPop: false);
    }
  }
}
