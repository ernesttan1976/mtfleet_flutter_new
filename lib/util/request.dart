import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:transport_flutter/constants.dart' as Constants;

class Request extends http.BaseClient {
  final Client _client = Client();

  Request();

  String endpoint(String url) {
    return '${Constants.SERVER_URI_API}/$url';
  }

  void _logEndpoint(String method, Uri url) {
    debugPrint('[${method.toUpperCase().toString()}] ${endpoint(url.toString()).toString()}');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Content-type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['Cache-Control'] = 'no-cache';

    return this._client.send(request);
  }

  @override
  Future<http.Response> head(url, {Map<String, String>? headers}) {
    this._logEndpoint('head', url);
    return this._client.head(Uri.parse(endpoint(url.path)), headers: headers);
  }

  @override
  Future<http.Response> get(url, {Map<String, String>? headers}) async {
    this._logEndpoint('get', url);
    final _storage = FlutterSecureStorage();
    var _token = await _storage.read(key: Constants.storageBearer);

    return this._client.get(
      Uri.parse(endpoint(url.toString())),
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: 'Bearer $_token',
      },
    );
  }

  @override
  Future<http.Response> post(url, {Map<String, String>? headers, body, Encoding? encoding}) async {
    this._logEndpoint('post', url);
    final _storage = FlutterSecureStorage();
    var _token = await _storage.read(key: Constants.storageBearer);
    return this._client.post(Uri.parse(endpoint(url.path)),
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $_token',
        },
        body: body,
        encoding: encoding);
  }

  @override
  Future<http.Response> put(url, {Map<String, String>? headers, body, Encoding? encoding}) {
    this._logEndpoint('put', url);
    return this._client.put(Uri.parse(endpoint(url.path)), headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> patch(url, {Map<String, String>? headers, body, Encoding? encoding}) async {
    this._logEndpoint('patch', url);
    final _storage = FlutterSecureStorage();
    var _token = await _storage.read(key: Constants.storageBearer);
    return this._client.patch(Uri.parse(endpoint(url.path)),
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          HttpHeaders.authorizationHeader: 'Bearer $_token',
        },
        body: body,
        encoding: encoding);
  }
}
