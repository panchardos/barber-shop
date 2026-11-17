import 'dart:io';

import 'package:barber_shop_server/api/server_api.dart';
import 'package:barber_shop_server/api/static_handler.dart';
import 'package:barber_shop_server/auth/auth_service.dart';
import 'package:barber_shop_server/config/server_environment.dart';
import 'package:barber_shop_server/database/server_database.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final env = ServerEnvironment.load();

  final db = await ServerDatabase.open(path: env.dbPath);
  final auth = AuthService(
    adminUser: env.adminUser,
    adminPassword: env.adminPassword,
    tokenTtl: env.adminTokenTtl,
  );
  final api = ServerApi(
    db: db,
    auth: auth,
    demoResetEnabled: env.demoResetEnabled,
    corsOrigin: env.corsOrigin,
  );

  final apiHandler = api.handler;
  final webHandler = createWebHandler(env.webDir);

  Future<Response> handler(Request request) async {
    if (request.url.path == 'api' || request.url.path.startsWith('api/')) {
      return apiHandler(request);
    }
    return webHandler(request);
  }

  final server = await shelf_io.serve(handler, env.host, env.port);

  stdout.writeln('La Nota Barber Shop - servidor de demo');
  stdout.writeln('API y web: http://localhost:${server.port}');
  stdout.writeln('Base de datos: ${env.dbPath}');
  stdout.writeln(
    'Reset de demo: ${env.demoResetEnabled ? 'habilitado' : 'deshabilitado'}',
  );

  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );
  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      stdout.writeln(
        'Desde el celular: http://${address.address}:${server.port}',
      );
    }
  }

  Future<void> shutdown() async {
    await server.close(force: true);
    await db.close();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown());
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => shutdown());
  }
}
