import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_session.dart';

class ApiClientException implements Exception {
  final int? statusCode;
  final String message;

  const ApiClientException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final Uri baseUrl;
  final AuthSession? session;
  final http.Client _client;

  ApiClient({required this.baseUrl, this.session, http.Client? client})
    : _client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send('POST', path, body: body, query: query);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send('PATCH', path, body: body, query: query);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _send('PUT', path, body: body, query: query);
  }

  Future<dynamic> delete(String path, {Map<String, String>? query}) {
    return _send('DELETE', path, query: query);
  }

  void close() {
    _client.close();
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = baseUrl.replace(
      path: path,
      queryParameters: query == null || query.isEmpty ? null : query,
    );

    final headers = <String, String>{'accept': 'application/json'};
    if (body != null) {
      headers['content-type'] = 'application/json';
    }
    final token = session?.token;
    if (token != null && token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }

    final encodedBody = body == null ? null : jsonEncode(body);

    late http.Response response;
    try {
      response = switch (method) {
        'GET' => await _client.get(uri, headers: headers),
        'POST' => await _client.post(uri, headers: headers, body: encodedBody),
        'PATCH' => await _client.patch(
          uri,
          headers: headers,
          body: encodedBody,
        ),
        'PUT' => await _client.put(uri, headers: headers, body: encodedBody),
        'DELETE' => await _client.delete(uri, headers: headers),
        _ => throw ArgumentError('Método HTTP no soportado: $method'),
      };
    } on http.ClientException catch (error) {
      throw ApiClientException(
        null,
        'No se pudo conectar con el servidor: ${error.message}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        throw ApiClientException(
          response.statusCode,
          'El servidor devolvió una respuesta inválida.',
        );
      }
    }

    throw ApiClientException(response.statusCode, _errorMessage(response));
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Se usa el cuerpo o el status.
    }

    final body = response.body.trim();
    if (body.isNotEmpty) return body;
    return 'Error HTTP ${response.statusCode}.';
  }
}
