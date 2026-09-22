import '../../domain/ports/configuracion_repository.dart';

class InMemoryConfiguracionAdapter implements ConfiguracionRepository {
  String _apertura = "09:00";
  String _cierre = "20:00";
  int _duracionBloque = 30;
  bool _modoOscuro = false;

  @override
  Future<void> saveHorarioAtencion({
    required String apertura,
    required String cierre,
    required int duracionBloqueMinutos,
  }) async {
    _apertura = apertura;
    _cierre = cierre;
    _duracionBloque = duracionBloqueMinutos;
  }

  @override
  Future<Map<String, dynamic>> getHorarioAtencion() async {
    return {
      'apertura': _apertura,
      'cierre': _cierre,
      'duracionBloqueMinutos': _duracionBloque,
    };
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