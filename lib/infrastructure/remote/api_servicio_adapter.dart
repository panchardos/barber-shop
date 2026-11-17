import '../../domain/entities/servicio.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/servicio_repository.dart';
import 'api_client.dart';

class ApiServicioAdapter implements ServicioRepository {
  final ApiClient _client;

  ApiServicioAdapter(this._client);

  @override
  Future<List<Servicio>> findAll() async {
    try {
      final response = await _client.get('/api/services');
      if (response is! List) {
        throw PersistenceFailureException(
          'El servidor devolvió un catálogo inválido.',
        );
      }
      return response
          .map((item) => _servicioFromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<Servicio?> findById(String id) async {
    final servicios = await findAll();
    for (final servicio in servicios) {
      if (servicio.id == id) return servicio;
    }
    return null;
  }

  @override
  Future<void> save(Servicio servicio) async {
    try {
      await _client.post(
        '/api/services',
        body: {
          'id': servicio.id,
          'nombre': servicio.nombre,
          'duracionMinutos': servicio.duracionMinutos,
          'precio': servicio.precio,
        },
      );
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  @override
  Future<void> updatePrecio(String id, double nuevoPrecio) async {
    try {
      await _client.patch(
        '/api/services/$id/price',
        body: {'precio': nuevoPrecio},
      );
    } on ApiClientException catch (error) {
      throw PersistenceFailureException(error.message);
    }
  }

  Servicio _servicioFromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      duracionMinutos: json['duracionMinutos'] as int,
      precio: (json['precio'] as num).toDouble(),
    );
  }
}
