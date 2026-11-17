import 'dart:convert';

import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/infrastructure/remote/api_auth_adapter.dart';
import 'package:barber_shop/infrastructure/remote/api_bloqueo_adapter.dart';
import 'package:barber_shop/infrastructure/remote/api_client.dart';
import 'package:barber_shop/infrastructure/remote/api_configuracion_adapter.dart';
import 'package:barber_shop/infrastructure/remote/api_servicio_adapter.dart';
import 'package:barber_shop/infrastructure/remote/api_turno_adapter.dart';
import 'package:barber_shop/infrastructure/remote/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Adaptadores remotos', () {
    late AuthSession session;
    late ApiClient client;

    setUp(() {
      session = AuthSession();
      client = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
      );
    });

    tearDown(() {
      client.close();
    });

    test('el cliente agrega el token de sesión', () async {
      session.setToken('token-123');
      String? authorization;

      final mock = MockClient((request) async {
        authorization = request.headers['authorization'];
        return http.Response('{}', 200);
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );

      await api.get('/api/services');

      expect(authorization, 'Bearer token-123');
      api.close();
    });

    test('login guarda el token en la sesión', () async {
      final mock = MockClient((request) async {
        expect(request.url.path, '/api/auth/login');
        return http.Response(
          jsonEncode({'token': 'abc'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final auth = ApiAuthAdapter(api, session);

      await auth.login(usuario: 'admin', password: 'clave');

      expect(session.token, 'abc');
      expect(auth.estaAutenticado, isTrue);
      api.close();
    });

    test('login inválido lanza excepción de autenticación', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Credenciales inválidas.'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final auth = ApiAuthAdapter(api, session);

      await expectLater(
        auth.login(usuario: 'admin', password: 'mal'),
        throwsA(isA<AuthenticationFailureException>()),
      );
      api.close();
    });

    test('consulta ocupados sin token para el cliente', () async {
      String? path;
      final mock = MockClient((request) async {
        path = request.url.path;
        return http.Response(
          jsonEncode([
            {'hora': '10:00', 'duracionMinutos': 30},
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final adapter = ApiTurnoAdapter(api, session);

      final turnos = await adapter.findByDate('2030-01-15');

      expect(path, '/api/ocupados');
      expect(turnos, hasLength(1));
      expect(turnos.first.hora, '10:00');
      expect(turnos.first.servicio.duracionMinutos, 30);
      api.close();
    });

    test('consulta turnos completos con token de admin', () async {
      session.setToken('admin-token');
      String? path;
      final mock = MockClient((request) async {
        path = request.url.path;
        return http.Response(
          jsonEncode([
            {
              'id': 'TRN-1',
              'clienteNombre': 'Ana Pérez',
              'clienteTelefono': '2611234567',
              'servicioId': '1',
              'servicioNombre': 'Corte',
              'servicioDuracion': 30,
              'servicioPrecio': 5000,
              'fechaYMD': '2030-01-15',
              'hora': '10:00',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final adapter = ApiTurnoAdapter(api, session);

      final turnos = await adapter.findByDate('2030-01-15');

      expect(path, '/api/appointments');
      expect(turnos.first.cliente.nombre, 'Ana Pérez');
      api.close();
    });

    test('reserva ocupada lanza HorarioNoDisponibleException', () async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'El horario no está disponible.'}),
          409,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final adapter = ApiTurnoAdapter(api, session);
      final turno = Turno(
        id: 'TRN-1',
        cliente: Cliente(nombre: 'Ana', telefono: '2611234567'),
        servicio: Servicio(
          id: '1',
          nombre: 'Corte',
          duracionMinutos: 30,
          precio: 5000,
        ),
        fechaYMD: '2030-01-15',
        hora: '10:00',
      );

      await expectLater(
        adapter.save(turno),
        throwsA(isA<HorarioNoDisponibleException>()),
      );
      api.close();
    });

    test('parsea y envía bloqueos', () async {
      final mock = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'id': 'BLQ-1',
                'fechaYMD': '2030-01-15',
                'todoElDia': false,
                'horaInicio': '10:00',
                'horaFin': '11:00',
                'motivo': 'Trámite',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200);
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final adapter = ApiBloqueoAdapter(api);

      final bloqueos = await adapter.findByDate('2030-01-15');
      expect(bloqueos.single.id, 'BLQ-1');
      expect(bloqueos.single.horaInicio, '10:00');
      expect(bloqueos.single.motivo, 'Trámite');

      await adapter.save(bloqueos.single);
      await adapter.delete('BLQ-1');
      api.close();
    });

    test('parsea servicios y configuración', () async {
      final mock = MockClient((request) async {
        if (request.url.path == '/api/services') {
          return http.Response(
            jsonEncode([
              {
                'id': '1',
                'nombre': 'Corte',
                'duracionMinutos': 30,
                'precio': 5000,
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'apertura': '09:00',
            'cierre': '20:00',
            'duracionBloqueMinutos': 30,
            'pausaInicio': '13:00',
            'pausaFin': '14:00',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = ApiClient(
        baseUrl: Uri.parse('http://demo.test'),
        session: session,
        client: mock,
      );
      final servicios = await ApiServicioAdapter(api).findAll();
      final config = await ApiConfiguracionAdapter(api).getHorarioAtencion();

      expect(servicios.single.nombre, 'Corte');
      expect(config.apertura, '09:00');
      expect(config.pausaInicio, '13:00');
      expect(config.pausaFin, '14:00');
      api.close();
    });
  });
}
