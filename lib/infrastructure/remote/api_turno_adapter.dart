import '../../domain/entities/cliente.dart';
import '../../domain/entities/estado_turno.dart';
import '../../domain/entities/servicio.dart';
import '../../domain/entities/turno.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/turno_repository.dart';
import 'api_client.dart';
import 'auth_session.dart';

class ApiTurnoAdapter implements TurnoRepository {
  final ApiClient _client;
  final AuthSession _session;

  ApiTurnoAdapter(this._client, this._session);

  @override
  Future<void> save(Turno turno) async {
    try {
      await _client.post(
        '/api/appointments',
        body: {
          'id': turno.id,
          'clienteNombre': turno.cliente.nombre,
          'clienteTelefono': turno.cliente.telefono,
          'servicioId': turno.servicio.id,
          'fechaYMD': turno.fechaYMD,
          'hora': turno.hora,
        },
      );
    } on ApiClientException catch (error) {
      if (error.statusCode == 409) {
        throw HorarioNoDisponibleException(turno.fechaYMD, turno.hora);
      }
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<List<Turno>> findByDate(String fechaYMD) async {
    try {
      if (_session.isAuthenticated) {
        final response = await _client.get(
          '/api/appointments',
          query: {'fecha': fechaYMD},
        );
        return _listaTurnos(response);
      }

      final response = await _client.get(
        '/api/ocupados',
        query: {'fecha': fechaYMD},
      );
      if (response is! List) {
        throw PersistenceFailureException(
          'El servidor devolvió horarios inválidos.',
        );
      }
      return response.map((item) {
        final json = item as Map<String, dynamic>;
        return Turno(
          id: 'ocupado-${json['hora']}',
          cliente: Cliente(nombre: 'Reservado', telefono: ''),
          servicio: Servicio(
            id: '',
            nombre: '',
            duracionMinutos: json['duracionMinutos'] as int,
            precio: 0,
          ),
          fechaYMD: fechaYMD,
          hora: json['hora'] as String,
        );
      }).toList();
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<void> cancelar(String id) async {
    try {
      await _client.delete('/api/appointments/$id');
    } on ApiClientException catch (error) {
      if (error.statusCode == 404) {
        throw TurnoNotFoundException(id);
      }
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<List<Turno>> findByClienteTelefono(String telefono) async {
    try {
      final response = await _client.get(
        '/api/appointments',
        query: {'telefono': telefono},
      );
      return _listaTurnos(response);
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  List<Turno> _listaTurnos(dynamic response) {
    if (response is! List) {
      throw PersistenceFailureException(
        'El servidor devolvió turnos inválidos.',
      );
    }
    return response.map((item) {
      return _turnoFromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Turno _turnoFromJson(Map<String, dynamic> json) {
    return Turno(
      id: json['id'] as String,
      cliente: Cliente(
        nombre: json['clienteNombre'] as String,
        telefono: json['clienteTelefono'] as String,
      ),
      servicio: Servicio(
        id: json['servicioId'] as String,
        nombre: json['servicioNombre'] as String,
        duracionMinutos: json['servicioDuracion'] as int,
        precio: (json['servicioPrecio'] as num).toDouble(),
      ),
      fechaYMD: json['fechaYMD'] as String,
      hora: json['hora'] as String,
      estado: EstadoTurno.fromValue(json['estado'] as String?),
    );
  }
}
