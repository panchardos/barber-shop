import 'dart:io';

import 'package:dotenv/dotenv.dart';

class ServerEnvironment {
  final String host;
  final int port;
  final String adminUser;
  final String adminPassword;
  final Duration adminTokenTtl;
  final bool demoResetEnabled;
  final String dbPath;
  final String webDir;
  final String corsOrigin;

  const ServerEnvironment({
    required this.host,
    required this.port,
    required this.adminUser,
    required this.adminPassword,
    required this.adminTokenTtl,
    required this.demoResetEnabled,
    required this.dbPath,
    required this.webDir,
    required this.corsOrigin,
  });

  factory ServerEnvironment.load({String envFile = '.env'}) {
    final env = DotEnv(includePlatformEnvironment: true);
    if (File(envFile).existsSync()) {
      env.load([envFile]);
    }

    String required(String key) {
      final value = env[key];
      if (value == null || value.trim().isEmpty) {
        throw StateError(
          'Falta la variable de entorno $key. Revisá $envFile o .env.example.',
        );
      }
      return value.trim();
    }

    String optional(String key, String fallback) {
      final value = env[key];
      if (value == null || value.trim().isEmpty) {
        return fallback;
      }
      return value.trim();
    }

    final port = int.tryParse(optional('PORT', '8080'));
    if (port == null || port <= 0) {
      throw StateError('PORT debe ser un número positivo.');
    }

    final tokenTtl = int.tryParse(optional('ADMIN_TOKEN_TTL_MINUTES', '480'));
    if (tokenTtl == null || tokenTtl <= 0) {
      throw StateError('ADMIN_TOKEN_TTL_MINUTES debe ser positivo.');
    }

    return ServerEnvironment(
      host: optional('HOST', '0.0.0.0'),
      port: port,
      adminUser: required('ADMIN_USER'),
      adminPassword: required('ADMIN_PASSWORD'),
      adminTokenTtl: Duration(minutes: tokenTtl),
      demoResetEnabled: optional('DEMO_RESET', 'false').toLowerCase() == 'true',
      dbPath: optional('DB_PATH', 'data/demo.db'),
      webDir: optional('WEB_DIR', '../build/web'),
      corsOrigin: optional('CORS_ORIGIN', '*'),
    );
  }
}
