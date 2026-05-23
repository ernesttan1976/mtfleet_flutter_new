import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:transport_flutter/constants.dart' as constants;

class Request extends http.BaseClient {
  final Client _client = Client();

  Request();

  String endpoint(String url) {
    return '${constants.SERVER_URI_API}/$url';
  }

  void _logEndpoint(String method, Uri url) {
    debugPrint('[${method.toUpperCase().toString()}] ${endpoint(url.toString()).toString()}');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Content-type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['Cache-Control'] = 'no-cache';

    return _client.send(request);
  }

  @override
  Future<http.Response> head(url, {Map<String, String>? headers}) {
    _logEndpoint('head', url);
    return _client.head(Uri.parse(endpoint(url.path)), headers: headers);
  }

  @override
  Future<http.Response> get(url, {Map<String, String>? headers}) async {
    _logEndpoint('get', url);
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: constants.storageBearer);

    return _client.get(
      Uri.parse(endpoint(url.toString())),
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
  }

  @override
  Future<http.Response> post(url, {Map<String, String>? headers, body, Encoding? encoding}) async {
    _logEndpoint('post', url);
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: constants.storageBearer);
    return _client.post(Uri.parse(endpoint(url.path)),
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: body,
        encoding: encoding);
  }

  @override
  Future<http.Response> put(url, {Map<String, String>? headers, body, Encoding? encoding}) {
    _logEndpoint('put', url);
    return _client.put(Uri.parse(endpoint(url.path)), headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> patch(url, {Map<String, String>? headers, body, Encoding? encoding}) async {
    _logEndpoint('patch', url);
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: constants.storageBearer);
    return _client.patch(Uri.parse(endpoint(url.path)),
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: body,
        encoding: encoding);
  }
}
