import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'api_exception.dart';

Response jsonResponse(Object? body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

Response errorResponse(int status, String message) {
  return jsonResponse({'error': message}, status: status);
}

Future<Map<String, dynamic>> readJson(Request request) async {
  final raw = await request.readAsString();
  if (raw.trim().isEmpty) {
    throw const ApiException(400, 'El cuerpo JSON es obligatorio.');
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    // Se traduce abajo.
  }

  throw const ApiException(400, 'JSON inválido.');
}

String? bearerToken(Request request) {
  final header = request.headers['authorization'];
  if (header == null || !header.startsWith('Bearer ')) {
    return null;
  }
  return header.substring(7).trim();
}
