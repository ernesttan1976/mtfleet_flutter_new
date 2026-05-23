import 'dart:convert';

import 'package:dio/dio.dart' as dio_client;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transport_flutter/util/currentUserData.dart';
import 'package:transport_flutter/util/request.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({Key? key}) : super(key: key);

  @override
  _AppLoadingScreenState createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen> {
  final storage = FlutterSecureStorage();
  final dio = dio_client.Dio();
  final request = Request();

  void onError() {
    storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void checkAuth() async {
    // storage.deleteAll();
    var authString = await storage.read(key: "auth");
    print("Auth: $authString");
    if (authString != null) {
      // Verifying if the user is still valid.
      try {
        var data = json.decode((await request.get(Uri.parse("users/me"))).body);
        print("NEW JSON: $data");
        var currentRole = await getCurrentRole();
        print("Current Role: $currentRole");
        if (SUPPORTED_ROLES.contains(currentRole)) {
          switch (currentRole) {
            case "DRIVER":
            case "PRE_APPROVED_DRIVER":
              print('Case 1');
              Navigator.pushReplacementNamed(context, '/driver');
              break;
            case "MAC":
              print('Case 2');
              Navigator.pushReplacementNamed(context, '/mac');
              break;
            case "APPROVING_OFFICER":
              print('Case 3');
              Navigator.pushReplacementNamed(context, '/approvingOfficer');
              break;
            default:
              print('Case 4');
              Navigator.pushReplacementNamed(context, '/login');
              return;
          }
          return;
        } else {
          print("Invalid Authentication");
          await storage.delete(key: "auth");
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      } on dio_client.DioException catch (error) {
        print('DIO Error: $error');
        onError();
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        print('Error: $e');
        Navigator.pushReplacementNamed(context, '/login');
        // onError();
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
