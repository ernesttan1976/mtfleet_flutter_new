import 'dart:convert';

import 'package:async/async.dart';
import "package:dio/dio.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:transport_flutter/constants.dart' as Constants;

class AuthedDio {
  // Singleton pattern
  static final AuthedDio _dbManager = new AuthedDio._internal();

  AuthedDio._internal();

  static AuthedDio get instance => _dbManager;

  // Members
  static Dio? _dio;
  final _initDioMemoizer = AsyncMemoizer<Dio>();

  Future<Dio> get dio async {
    _dio = await _initDio();
    return _dio!;
  }

  Future<Dio> _initDio() async {
    var storage = FlutterSecureStorage();
    String? token = await storage.read(key: Constants.storageBearer);
    Logger().e("Token $token");
    BaseOptions options = new BaseOptions(
        baseUrl: Constants.SERVER_URI_API, headers: {"Authorization": "Bearer $token", "Accept": "*/*"});

    return Dio(options);
  }
}

class AuthedDioAPI {
  // Singleton pattern
  static final AuthedDioAPI _dbManager = new AuthedDioAPI._internal();

  AuthedDioAPI._internal();

  static AuthedDioAPI get instance => _dbManager;

  // Members
  static Dio? _dio;
  final _initDioMemoizer = AsyncMemoizer<Dio>();

  Future<Dio> get dio async {
    if (_dio != null) return _dio!;

    // if _database is null we instantiate it
    _dio = await _initDioMemoizer.runOnce(() async {
      return await _initDio();
    });

    return _dio!;
  }

  Future<Dio> _initDio() async {
    var storage = FlutterSecureStorage();
    String? authString = await storage.read(key: "auth");
    var auth = await json.decode(authString!);
    String jwt = auth['jwt'];

    BaseOptions options = new BaseOptions(
        baseUrl: Constants.SERVER_URI_API, headers: {"Authorization": "Bearer $jwt", "Accept": "*/*"});

    return Dio(options);
  }
}
