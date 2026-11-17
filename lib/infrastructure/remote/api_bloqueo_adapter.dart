import '../../domain/entities/bloqueo.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/bloqueo_repository.dart';
import 'api_client.dart';

class ApiBloqueoAdapter implements BloqueoRepository {
  final ApiClient _client;

  ApiBloqueoAdapter(this._client);

  @override
  Future<List<Bloqueo>> findByDate(String fechaYMD) async {
    try {
      final response = await _client.get(
        '/api/bloqueos',
        query: {'fecha': fechaYMD},
      );
      if (response is! List) {
        throw PersistenceFailureException(
          'El servidor devolvió bloqueos inválidos.',
        );
      }
      return response
          .map((item) => _fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<void> save(Bloqueo bloqueo) async {
    try {
      await _client.post(
        '/api/bloqueos',
        body: {
          'id': bloqueo.id,
          'fechaYMD': bloqueo.fechaYMD,
          'todoElDia': bloqueo.todoElDia,
          'horaInicio': bloqueo.horaInicio,
          'horaFin': bloqueo.horaFin,
          'motivo': bloqueo.motivo,
        },
      );
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.delete('/api/bloqueos/$id');
    } on ApiClientException catch (error) {
      if (error.statusCode == 404) {
        throw BloqueoNotFoundException(id);
      }
      throw PersistenceFailureException(error.message);
    }
  }

  Bloqueo _fromJson(Map<String, dynamic> json) {
    return Bloqueo(
      id: json['id'] as String,
      fechaYMD: json['fechaYMD'] as String,
      todoElDia: json['todoElDia'] as bool? ?? false,
      horaInicio: json['horaInicio'] as String?,
      horaFin: json['horaFin'] as String?,
      motivo: json['motivo'] as String?,
    );
  }
}
