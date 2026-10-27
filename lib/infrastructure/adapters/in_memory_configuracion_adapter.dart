import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/ports/configuracion_repository.dart';

class InMemoryConfiguracionAdapter implements ConfiguracionRepository {
  ConfiguracionAgenda _configuracion = ConfiguracionAgenda.defaults();
  bool _modoOscuro = false;

  @override
  Future<void> saveHorarioAtencion(ConfiguracionAgenda configuracion) async {
    _configuracion = configuracion;
  }

  @override
  Future<ConfiguracionAgenda> getHorarioAtencion() async {
    return _configuracion;
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
