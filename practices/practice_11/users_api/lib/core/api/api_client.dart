import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    this.host = const String.fromEnvironment(
      'API_HOST',
      defaultValue: 'jsonplaceholder.typicode.com',
    ),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String host;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final response = await _send(
      () => _client.get(_uri(path, query), headers: headers),
    );

    _check(response);
    _log(response);

    return response;
  }

  Future<http.Response> post(String path, Object body) async {
    final response = await _send(
      () => _client.post(
        _uri(path),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );

    _check(response);
    _log(response);

    return response;
  }

  dynamic decode(http.Response response) => _decode(response);

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.https(host, path, query);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response) {
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }

    if (response.statusCode == 404) {
      throw const NotFoundException();
    }

    if (response.statusCode >= 500) {
      throw ServerException(response.statusCode);
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw BadResponseException(error.message);
    }
  }

  void _log(http.Response response) {
    if (!kDebugMode) return;

    log(
      '${response.statusCode} ${response.request?.method} '
      '${response.request?.url}',
      name: 'api',
    );
  }
}
