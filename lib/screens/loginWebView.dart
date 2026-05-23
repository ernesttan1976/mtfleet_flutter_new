import 'dart:convert';
import 'dart:io';

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

class LoginAuthScreen extends StatefulWidget {
  const LoginAuthScreen({Key? key}) : super(key: key);

  @override
  State<LoginAuthScreen> createState() => _LoginAuthScreenState();
}

class _LoginAuthScreenState extends State<LoginAuthScreen> {
  final _storage = FlutterSecureStorage();
  final logger = Logger();

  @override
  void initState() {
    super.initState();

    // Enable virtual display for Android.
    if (Platform.isAndroid) {
      PlatformWebViewControllerCreationParams params =
          const PlatformWebViewControllerCreationParams();
      WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      WebViewWidget(controller: controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    String loginUrl = '${constants.SERVER_URI_API}/auth/microsoft/login';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In Using Microsoft'),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(loginUrl))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                if (!mounted) return;

                if (url.startsWith(constants.AUTH_CALLBACK)) {
                  try {
                    final token = url.split('access_token=')[1];
                    await _storage.write(key: constants.storageBearer, value: token);

                    final httpRequest = request.Request();
                    final response = await httpRequest.get(Uri.parse('users/me'));
                    final data = json.decode(response.body) as Map<String, dynamic>;

                    logger.e('loginData-> $data');

                    final roles = <String>[];
                    for (final role in (data['roles'] as List)) {
                      if (supportedRoles.contains(role)) {
                        roles.add(role as String);
                      }
                    }

                    if (roles.isNotEmpty) {
                      final currentRole = roles.first;
                      final authData = {
                        'user': {...data, 'otherRoles': []},
                      };

                      await _storage.write(key: 'auth', value: json.encode(authData));
                      await _storage.write(key: 'currentRole', value: currentRole);

                      if (roles.contains('APPROVING_OFFICER')) {
                        _setFirebaseToken(data);
                      } else {
                        _deleteFirebaseToken(data);
                      }

                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/appLoading');
                    } else {
                      if (!mounted) return;

                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(
                            error:
                                "You don't have a proper role to access the application. Please contact the administration.",
                          ),
                        ),
                      );
                    }
                  } catch (e, trace) {
                    logger.e('Error In Login $e $trace');
                    await Sentry.captureException(e, stackTrace: trace);

                    if (!mounted) return;

                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                          error:
                              'There was some internal error while logging you in. Please try again!',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
      ),
    );
  }

  Future<void> _setFirebaseToken(dynamic data) async {
    try {
      final client = AuthedDio.instance.dio;
      final dioClient = await client;
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      try {
        await messaging.subscribeToTopic('User-${data['id']}');
      } catch (e) {
        logger.e('SubScribeToTopic $e');
      }

      final token = await messaging.getToken();
      final dataJSON = jsonEncode({'token': token});
      final response = await dioClient.post('/users/me/fcm/subscribe', data: dataJSON);
      logger.e('Firebase Token $response');

      if (response.statusCode != 201 && mounted) {
        showAlertDialog(context, 'Error', response.data['message'], isPop: false);
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, 'Error', e.toString());
      }
    }
  }

  Future<void> _deleteFirebaseToken(dynamic data) async {
    try {
      final client = AuthedDio.instance.dio;
      final dioClient = await client;
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      try {
        await messaging.unsubscribeFromTopic('User-${data['id']}');
      } catch (e) {
        logger.e('unsubscribeFromTopic $e');
      }

      final token = await messaging.getToken();
      final dataJSON = jsonEncode({'token': token});
      await dioClient.post('/users/me/fcm/unsubscribe', data: dataJSON);
      await messaging.deleteToken();
    } catch (e) {
      if (mounted) {
        showAlertDialog(context, 'Error', e.toString(), isPop: false);
      }
    }
  }
}
