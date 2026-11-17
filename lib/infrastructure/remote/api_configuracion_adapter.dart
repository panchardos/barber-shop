import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/configuracion_repository.dart';
import 'api_client.dart';

class ApiConfiguracionAdapter implements ConfiguracionRepository {
  final ApiClient _client;
  bool _modoOscuro = false;

  ApiConfiguracionAdapter(this._client);

  @override
  Future<void> saveHorarioAtencion(ConfiguracionAgenda configuracion) async {
    try {
      await _client.put(
        '/api/config',
        body: {
          'apertura': configuracion.apertura,
          'cierre': configuracion.cierre,
          'duracionBloqueMinutos': configuracion.duracionBloqueMinutos,
        },
      );
    } on ApiClientException catch (error) {
      throw ConfiguracionFailureException(error.message);
    }
  }

  @override
  Future<ConfiguracionAgenda> getHorarioAtencion() async {
    try {
      final response = await _client.get('/api/config');
      if (response is! Map<String, dynamic>) {
        throw ConfiguracionFailureException(
          'El servidor devolvió una configuración inválida.',
        );
      }

      return ConfiguracionAgenda(
        apertura: response['apertura'] as String,
        cierre: response['cierre'] as String,
        duracionBloqueMinutos: response['duracionBloqueMinutos'] as int,
      );
    } on ApiClientException catch (error) {
      throw ConfiguracionFailureException(error.message);
    }
  }

  @override
  Future<void> saveModoOscuro(bool esModoOscuro) async {
    _modoOscuro = esModoOscuro;
  }

  @override
  Future<bool> getModoOscuro() async {
    return _modoOscuro;
  }
}
