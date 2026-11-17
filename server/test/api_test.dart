import 'dart:convert';
import 'dart:io';

import 'package:barber_shop_server/api/server_api.dart';
import 'package:barber_shop_server/auth/auth_service.dart';
import 'package:barber_shop_server/database/server_database.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  late ServerDatabase db;
  late HttpServer server;
  late http.Client client;
  late String baseUrl;

  setUp(() async {
    db = await ServerDatabase.open(path: inMemoryDatabasePath);
    final auth = AuthService(
      adminUser: 'admin',
      adminPassword: 'clave-demo',
      tokenTtl: const Duration(minutes: 5),
    );
    final api = ServerApi(
      db: db,
      auth: auth,
      demoResetEnabled: true,
      corsOrigin: '*',
    );
    server = await shelf_io.serve(api.handler, '127.0.0.1', 0);
    baseUrl = 'http://${server.address.host}:${server.port}';
    client = http.Client();
  });

  tearDown(() async {
    client.close();
    await server.close(force: true);
    await db.close();
  });

  Future<http.Response> get(String path, {String? token}) {
    return client.get(
      Uri.parse('$baseUrl$path'),
      headers: {if (token != null) 'authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return client.patch(
      Uri.parse('$baseUrl$path'),
      headers: {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) {
    return client.put(
      Uri.parse('$baseUrl$path'),
      headers: {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {String? token}) {
    return client.delete(
      Uri.parse('$baseUrl$path'),
      headers: {if (token != null) 'authorization': 'Bearer $token'},
    );
  }

  Future<String> login() async {
    final response = await post('/api/auth/login', {
      'usuario': 'admin',
      'password': 'clave-demo',
    });
    expect(response.statusCode, 200);
    return (jsonDecode(response.body) as Map<String, dynamic>)['token']
        as String;
  }

  test('health responde correctamente', () async {
    final response = await get('/api/health');
    expect(response.statusCode, 200);
    expect(jsonDecode(response.body), {'status': 'ok'});
  });

  test('login correcto e incorrecto', () async {
    final malo = await post('/api/auth/login', {
      'usuario': 'admin',
      'password': 'incorrecta',
    });
    expect(malo.statusCode, 401);

    final token = await login();
    expect(token, isNotEmpty);
  });

  test('los endpoints de admin requieren token', () async {
    final response = await get('/api/appointments?fecha=2030-01-15');
    expect(response.statusCode, 401);
  });

  test('servicios y configuración públicos', () async {
    final services = await get('/api/services');
    expect(services.statusCode, 200);
    final servicesJson = jsonDecode(services.body) as List<dynamic>;
    expect(servicesJson, hasLength(4));

    final config = await get('/api/config');
    expect(config.statusCode, 200);
    final configJson = jsonDecode(config.body) as Map<String, dynamic>;
    expect(configJson['apertura'], '09:00');
  });

  test('reserva, conflicto, consulta y cancelación', () async {
    final token = await login();

    const fecha = '2030-01-15';
    final body = {
      'id': 'TRN-TEST-1',
      'clienteNombre': 'Ana Pérez',
      'clienteTelefono': '2611234567',
      'servicioId': '1',
      'fechaYMD': fecha,
      'hora': '10:00',
    };

    final created = await post('/api/appointments', body);
    expect(created.statusCode, 201);

    final repeated = await post('/api/appointments', {
      ...body,
      'id': 'TRN-TEST-2',
    });
    expect(repeated.statusCode, 409);

    final occupied = await get('/api/ocupados?fecha=$fecha');
    expect(occupied.statusCode, 200);
    final occupiedJson = jsonDecode(occupied.body) as List<dynamic>;
    expect(occupiedJson, hasLength(1));
    expect(occupiedJson.first['hora'], '10:00');
    expect(occupiedJson.first.containsKey('clienteNombre'), isFalse);

    final agenda = await get('/api/appointments?fecha=$fecha', token: token);
    expect(agenda.statusCode, 200);
    final agendaJson = jsonDecode(agenda.body) as List<dynamic>;
    expect(agendaJson, hasLength(1));
    expect(agendaJson.first['clienteNombre'], 'Ana Pérez');

    final history = await get(
      '/api/appointments?telefono=2611234567',
      token: token,
    );
    expect(history.statusCode, 200);
    expect(jsonDecode(history.body), hasLength(1));

    final canceled = await delete('/api/appointments/TRN-TEST-1', token: token);
    expect(canceled.statusCode, 200);

    final occupiedAfter = await get('/api/ocupados?fecha=$fecha');
    expect(jsonDecode(occupiedAfter.body), isEmpty);

    final historyAfter = await get(
      '/api/appointments?telefono=2611234567',
      token: token,
    );
    final historyAfterJson = jsonDecode(historyAfter.body) as List<dynamic>;
    expect(historyAfterJson, hasLength(1));
    expect(historyAfterJson.first['estado'], 'cancelado');
  });

  test('crear y actualizar servicio', () async {
    final token = await login();

    final created = await post('/api/services', {
      'id': '10',
      'nombre': 'Coloración',
      'duracionMinutos': 60,
      'precio': 12000,
    }, token: token);
    expect(created.statusCode, 201);

    final services = await get('/api/services');
    expect(jsonDecode(services.body), hasLength(5));

    final updated = await patch('/api/services/10/price', {
      'precio': 15000,
    }, token: token);
    expect(updated.statusCode, 200);
    expect((jsonDecode(updated.body) as Map<String, dynamic>)['precio'], 15000);

    final unauthorized = await post('/api/services', {
      'id': '11',
      'nombre': 'Otro',
      'duracionMinutos': 30,
      'precio': 1000,
    });
    expect(unauthorized.statusCode, 401);
  });

  test('actualizar configuración', () async {
    final token = await login();

    final updated = await put('/api/config', {
      'apertura': '10:00',
      'cierre': '18:00',
      'duracionBloqueMinutos': 45,
      'pausaInicio': '13:00',
      'pausaFin': '14:00',
      'diasLaborales': [1, 2, 3, 4, 5],
    }, token: token);
    expect(updated.statusCode, 200);

    final config = await get('/api/config');
    final json = jsonDecode(config.body) as Map<String, dynamic>;
    expect(json['apertura'], '10:00');
    expect(json['duracionBloqueMinutos'], 45);
    expect(json['pausaInicio'], '13:00');
    expect(json['pausaFin'], '14:00');
    expect(json['diasLaborales'], [1, 2, 3, 4, 5]);
  });

  test('bloqueos: crear, listar, bloquear reserva y eliminar', () async {
    final token = await login();

    final unauthorized = await post('/api/bloqueos', {
      'fechaYMD': '2030-01-15',
      'todoElDia': true,
    });
    expect(unauthorized.statusCode, 401);

    final created = await post('/api/bloqueos', {
      'id': 'BLQ-TEST',
      'fechaYMD': '2030-01-15',
      'todoElDia': false,
      'horaInicio': '10:00',
      'horaFin': '11:00',
      'motivo': 'Trámite',
    }, token: token);
    expect(created.statusCode, 201);

    final bloqueos = await get('/api/bloqueos?fecha=2030-01-15');
    expect(bloqueos.statusCode, 200);
    final bloqueosJson = jsonDecode(bloqueos.body) as List<dynamic>;
    expect(bloqueosJson, hasLength(1));
    expect(bloqueosJson.first['motivo'], 'Trámite');

    final appointment = await post('/api/appointments', {
      'id': 'TRN-BLOQUEADO',
      'clienteNombre': 'Ana Pérez',
      'clienteTelefono': '2611234567',
      'servicioId': '1',
      'fechaYMD': '2030-01-15',
      'hora': '10:00',
    });
    expect(appointment.statusCode, 409);

    final deleted = await delete('/api/bloqueos/BLQ-TEST', token: token);
    expect(deleted.statusCode, 200);

    final bloqueosDespues = await get('/api/bloqueos?fecha=2030-01-15');
    expect(jsonDecode(bloqueosDespues.body), isEmpty);
  });

  test('reset de demo protegido', () async {
    final token = await login();

    final unauthorized = await post('/api/demo/reset', {});
    expect(unauthorized.statusCode, 401);

    final reset = await post('/api/demo/reset', {}, token: token);
    expect(reset.statusCode, 200);

    final services = await get('/api/services');
    expect(jsonDecode(services.body), hasLength(4));
  });
}
