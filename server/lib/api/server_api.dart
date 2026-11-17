import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../auth/auth_service.dart';
import '../database/server_database.dart';
import '../domain/server_availability.dart';
import 'api_exception.dart';
import 'json_helpers.dart';

class ServerApi {
  final ServerDatabase db;
  final AuthService auth;
  final bool demoResetEnabled;
  final String corsOrigin;

  ServerApi({
    required this.db,
    required this.auth,
    required this.demoResetEnabled,
    required this.corsOrigin,
  });

  Handler get handler {
    final router = Router();

    router.get('/api/health', (Request request) {
      return jsonResponse({'status': 'ok'});
    });

    router.post('/api/auth/login', _login);
    router.post('/api/auth/logout', _logout);

    router.get('/api/services', _listServices);
    router.get('/api/config', _getConfig);
    router.get('/api/ocupados', _occupied);
    router.get('/api/bloqueos', _listBloqueos);
    router.post('/api/appointments', _createAppointment);

    router.post('/api/bloqueos', _createBloqueo);
    router.delete('/api/bloqueos/<id>', _deleteBloqueo);

    router.get('/api/appointments', _listAppointments);
    router.delete('/api/appointments/<id>', _cancelAppointment);

    router.post('/api/services', _createService);
    router.patch('/api/services/<id>/price', _updatePrice);
    router.put('/api/config', _updateConfig);
    router.post('/api/demo/reset', _resetDemo);

    return Pipeline()
        .addMiddleware(_cors())
        .addMiddleware(_errors())
        .addHandler(router.call);
  }

  Response? _authError(Request request) {
    if (!auth.validate(bearerToken(request))) {
      return errorResponse(401, 'No autorizado.');
    }
    return null;
  }

  Future<Response> _login(Request request) async {
    final body = await readJson(request);
    final usuario = _requiredString(body, 'usuario');
    final password = _requiredString(body, 'password');

    final token = auth.login(usuario, password);
    if (token == null) {
      return errorResponse(401, 'Credenciales inválidas.');
    }

    return jsonResponse({
      'token': token,
      'expiresAt': auth.expiryFor(token)?.toUtc().toIso8601String(),
    });
  }

  Future<Response> _logout(Request request) async {
    auth.logout(bearerToken(request));
    return jsonResponse({'ok': true});
  }

  Future<Response> _listServices(Request request) async {
    final rows = await db.listServices();
    return jsonResponse(rows.map(_serviceJson).toList());
  }

  Future<Response> _createService(Request request) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final body = await readJson(request);
    final nombre = _requiredString(body, 'nombre');
    final duracion = _requiredInt(body, 'duracionMinutos');
    final precio = _requiredDouble(body, 'precio');
    if (duracion <= 0 || precio <= 0) {
      throw const ApiException(
        400,
        'La duración y el precio deben ser mayores a cero.',
      );
    }

    final idBody = (body['id'] as String?)?.trim();
    final id = idBody == null || idBody.isEmpty
        ? 'SRV-${DateTime.now().microsecondsSinceEpoch}'
        : idBody;

    await db.insertService(
      id: id,
      nombre: nombre,
      duracionMinutos: duracion,
      precio: precio,
    );

    final service = await db.findService(id);
    return jsonResponse(_serviceJson(service!), status: 201);
  }

  Future<Response> _updatePrice(Request request, String id) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final body = await readJson(request);
    final precio = _requiredDouble(body, 'precio');
    if (precio <= 0) {
      throw const ApiException(400, 'El precio debe ser mayor a cero.');
    }

    final updated = await db.updateServicePrice(id, precio);
    if (!updated) {
      return errorResponse(404, 'Servicio no encontrado.');
    }

    final service = await db.findService(id);
    return jsonResponse(_serviceJson(service!));
  }

  Future<Response> _getConfig(Request request) async {
    final config = await db.getConfig();
    return jsonResponse(_configJson(config));
  }

  Future<Response> _updateConfig(Request request) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final body = await readJson(request);
    final apertura = _requiredString(body, 'apertura');
    final cierre = _requiredString(body, 'cierre');
    final duracion = _requiredInt(body, 'duracionBloqueMinutos');
    final pausaInicio = _optionalString(body, 'pausaInicio');
    final pausaFin = _optionalString(body, 'pausaFin');
    final diasLaborales = _diasLaborales(body['diasLaborales']);

    ServerAvailability.validateConfig(
      apertura: apertura,
      cierre: cierre,
      duracionBloqueMinutos: duracion,
      pausaInicio: pausaInicio,
      pausaFin: pausaFin,
      diasLaborales: diasLaborales,
    );

    await db.updateConfig(
      apertura: apertura,
      cierre: cierre,
      duracionBloqueMinutos: duracion,
      pausaInicio: pausaInicio,
      pausaFin: pausaFin,
      diasLaborales: diasLaborales,
    );

    final config = await db.getConfig();
    return jsonResponse(_configJson(config));
  }

  Future<Response> _occupied(Request request) async {
    final fecha = request.url.queryParameters['fecha']?.trim() ?? '';
    _validarFecha(fecha);
    final rows = await db.occupiedByDate(fecha);
    return jsonResponse(
      rows
          .map(
            (row) => {
              'hora': row['hora'],
              'duracionMinutos': row['servicio_duracion'],
            },
          )
          .toList(),
    );
  }

  Future<Response> _listBloqueos(Request request) async {
    final fecha = request.url.queryParameters['fecha']?.trim() ?? '';
    _validarFecha(fecha);
    final rows = await db.listBloqueos(fecha);
    return jsonResponse(rows.map(_bloqueoJson).toList());
  }

  Future<Response> _createBloqueo(Request request) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final body = await readJson(request);
    final fechaYMD = _requiredString(body, 'fechaYMD');
    _validarFecha(fechaYMD);
    final todoElDia = _boolOrDefault(body, 'todoElDia');

    String? horaInicio;
    String? horaFin;
    if (!todoElDia) {
      horaInicio = _requiredString(body, 'horaInicio');
      horaFin = _requiredString(body, 'horaFin');
      _validarHora(horaInicio);
      _validarHora(horaFin);
      if (horaInicio.compareTo(horaFin) >= 0) {
        throw const ApiException(
          400,
          'El bloqueo debe comenzar antes de terminar.',
        );
      }
    }

    final idBody = (body['id'] as String?)?.trim();
    final id = idBody == null || idBody.isEmpty
        ? 'BLQ-${DateTime.now().microsecondsSinceEpoch}'
        : idBody;

    await db.insertBloqueo(
      id: id,
      fechaYMD: fechaYMD,
      todoElDia: todoElDia,
      horaInicio: horaInicio,
      horaFin: horaFin,
      motivo: _optionalString(body, 'motivo'),
    );

    final row = (await db.listBloqueos(fechaYMD)).firstWhere(
      (item) => item['id'] == id,
    );
    return jsonResponse(_bloqueoJson(row), status: 201);
  }

  Future<Response> _deleteBloqueo(Request request, String id) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final deleted = await db.deleteBloqueo(id);
    if (!deleted) {
      return errorResponse(404, 'Bloqueo no encontrado.');
    }
    return jsonResponse({'ok': true});
  }

  Future<Response> _createAppointment(Request request) async {
    final body = await readJson(request);

    final clienteNombre = _requiredString(body, 'clienteNombre');
    final clienteTelefono = _requiredString(body, 'clienteTelefono');
    final servicioId = _requiredString(body, 'servicioId');
    final fechaYMD = _requiredString(body, 'fechaYMD');
    final hora = _requiredString(body, 'hora');
    _validarFecha(fechaYMD);
    _validarHora(hora);

    final service = await db.findService(servicioId);
    if (service == null) {
      return errorResponse(404, 'Servicio no encontrado.');
    }

    final config = await db.getConfig();
    final occupied = await db.occupiedByDate(fechaYMD);
    final bloqueos = await db.listBloqueos(fechaYMD);
    final disponible = ServerAvailability.isAvailable(
      fechaYMD: fechaYMD,
      hora: hora,
      config: config,
      service: service,
      occupied: occupied,
      bloqueos: bloqueos,
    );

    if (!disponible) {
      return errorResponse(409, 'El horario no está disponible.');
    }

    final idBody = (body['id'] as String?)?.trim();
    final id = idBody == null || idBody.isEmpty
        ? 'TRN-${DateTime.now().microsecondsSinceEpoch}'
        : idBody;

    await db.insertAppointment(
      id: id,
      clienteNombre: clienteNombre,
      clienteTelefono: clienteTelefono,
      servicioId: servicioId,
      servicioNombre: service['nombre'] as String,
      servicioDuracion: service['duracion_minutos'] as int,
      servicioPrecio: (service['precio'] as num).toDouble(),
      fechaYMD: fechaYMD,
      hora: hora,
    );

    final appointment = await db.findAppointment(id);
    return jsonResponse(_appointmentJson(appointment!), status: 201);
  }

  Future<Response> _listAppointments(Request request) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final fecha = request.url.queryParameters['fecha']?.trim();
    final telefono = request.url.queryParameters['telefono']?.trim();

    if ((fecha == null || fecha.isEmpty) &&
        (telefono == null || telefono.isEmpty)) {
      throw const ApiException(
        400,
        'Indicá fecha o telefono para consultar turnos.',
      );
    }

    final rows = fecha != null && fecha.isNotEmpty
        ? await db.appointmentsByDate(fecha)
        : await db.appointmentsByPhone(telefono!);

    return jsonResponse(rows.map(_appointmentJson).toList());
  }

  Future<Response> _cancelAppointment(Request request, String id) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    final canceled = await db.cancelAppointment(id);
    if (!canceled) {
      return errorResponse(404, 'Turno no encontrado o ya cancelado.');
    }

    return jsonResponse({'ok': true});
  }

  Future<Response> _resetDemo(Request request) async {
    final unauthorized = _authError(request);
    if (unauthorized != null) return unauthorized;

    if (!demoResetEnabled) {
      return errorResponse(403, 'El reset de demo está deshabilitado.');
    }

    await db.resetDemo();
    return jsonResponse({'ok': true});
  }

  Map<String, dynamic> _serviceJson(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'nombre': row['nombre'],
      'duracionMinutos': row['duracion_minutos'],
      'precio': (row['precio'] as num).toDouble(),
    };
  }

  Map<String, dynamic> _configJson(Map<String, dynamic> row) {
    return {
      'apertura': row['apertura'],
      'cierre': row['cierre'],
      'duracionBloqueMinutos': row['duracion_bloque_minutos'],
      'pausaInicio': row['pausa_inicio'],
      'pausaFin': row['pausa_fin'],
      'diasLaborales': _parseDiasLaborales(row['dias_laborales'] as String?),
    };
  }

  Map<String, dynamic> _bloqueoJson(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'fechaYMD': row['fecha_ymd'],
      'todoElDia': (row['todo_el_dia'] as int? ?? 0) == 1,
      'horaInicio': row['hora_inicio'],
      'horaFin': row['hora_fin'],
      'motivo': row['motivo'],
    };
  }

  Map<String, dynamic> _appointmentJson(Map<String, dynamic> row) {
    return {
      'id': row['id'],
      'clienteNombre': row['cliente_nombre'],
      'clienteTelefono': row['cliente_telefono'],
      'servicioId': row['servicio_id'],
      'servicioNombre': row['servicio_nombre'],
      'servicioDuracion': row['servicio_duracion'],
      'servicioPrecio': (row['servicio_precio'] as num).toDouble(),
      'fechaYMD': row['fecha_ymd'],
      'hora': row['hora'],
      'estado': row['estado'],
    };
  }

  String _requiredString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is! String || value.trim().isEmpty) {
      throw ApiException(400, 'El campo $key es obligatorio.');
    }
    return value.trim();
  }

  List<int> _diasLaborales(Object? value) {
    if (value == null) {
      return const [1, 2, 3, 4, 5, 6, 7];
    }
    if (value is! List) {
      throw const ApiException(400, 'diasLaborales debe ser una lista.');
    }
    final dias = value
        .whereType<num>()
        .map((dia) => dia.toInt())
        .where((dia) => dia >= 1 && dia <= 7)
        .toSet()
        .toList()
      ..sort();
    if (dias.isEmpty) {
      throw const ApiException(
        400,
        'Seleccioná al menos un día de atención.',
      );
    }
    return dias;
  }

  List<int> _parseDiasLaborales(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const [1, 2, 3, 4, 5, 6, 7];
    }
    final dias = value
        .split(',')
        .map((dia) => int.tryParse(dia.trim()))
        .whereType<int>()
        .where((dia) => dia >= 1 && dia <= 7)
        .toSet()
        .toList()
      ..sort();
    return dias.isEmpty ? const [1, 2, 3, 4, 5, 6, 7] : dias;
  }

  String? _optionalString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null) return null;
    if (value is! String) {
      throw ApiException(400, 'El campo $key debe ser texto.');
    }
    final texto = value.trim();
    return texto.isEmpty ? null : texto;
  }

  bool _boolOrDefault(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null) return false;
    if (value is bool) return value;
    throw ApiException(400, 'El campo $key debe ser booleano.');
  }

  int _requiredInt(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw ApiException(400, 'El campo $key debe ser numérico.');
    }
    return parsed;
  }

  double _requiredDouble(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw ApiException(400, 'El campo $key debe ser numérico.');
    }
    return parsed;
  }

  void _validarFecha(String fecha) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(fecha)) {
      throw const ApiException(400, 'La fecha debe tener formato YYYY-MM-DD.');
    }
  }

  void _validarHora(String hora) {
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(hora)) {
      throw const ApiException(400, 'La hora debe tener formato HH:MM.');
    }
  }

  Middleware _cors() {
    final headers = {
      'access-control-allow-origin': corsOrigin,
      'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'access-control-allow-headers': 'Content-Type, Authorization',
    };

    return (inner) {
      return (request) async {
        if (request.method == 'OPTIONS') {
          return Response(204, headers: headers);
        }
        final response = await inner(request);
        return response.change(headers: headers);
      };
    };
  }

  Middleware _errors() {
    return (inner) {
      return (request) async {
        try {
          return await inner(request);
        } on ApiException catch (error) {
          return errorResponse(error.status, error.message);
        } on FormatException catch (error) {
          return errorResponse(400, error.message);
        } on DatabaseException catch (error) {
          if (error.isUniqueConstraintError()) {
            return errorResponse(409, 'El horario ya está reservado.');
          }
          stderr.writeln('Error de base de datos: $error');
          return errorResponse(500, 'Error de base de datos.');
        } on StateError catch (error) {
          stderr.writeln('Error de estado: $error');
          return errorResponse(500, 'Error interno del servidor.');
        } catch (error) {
          stderr.writeln('Error interno: $error');
          return errorResponse(500, 'Error interno del servidor.');
        }
      };
    };
  }
}
