import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

Handler createWebHandler(String webDir) {
  final directory = Directory(webDir);
  final index = File(p.join(webDir, 'index.html'));

  if (!directory.existsSync()) {
    return (Request request) {
      return Response.notFound(
        'No se encontró el build web en $webDir. '
        'Ejecutá flutter build web --release.',
      );
    };
  }

  final staticHandler = createStaticHandler(
    webDir,
    defaultDocument: 'index.html',
  );

  return (Request request) async {
    if (request.method != 'GET' && request.method != 'HEAD') {
      return Response.notFound('Método no permitido.');
    }

    final response = await staticHandler(request);
    if (response.statusCode != 404) {
      return response;
    }

    if (!index.existsSync()) {
      return Response.notFound(
        'No se encontró el build web. Ejecutá flutter build web --release.',
      );
    }

    return Response.ok(
      index.openRead(),
      headers: const {'content-type': 'text/html; charset=utf-8'},
    );
  };
}
