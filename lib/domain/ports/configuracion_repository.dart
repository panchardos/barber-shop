import '../entities/configuracion_agenda.dart';

abstract class ConfiguracionRepository {
  Future<void> saveHorarioAtencion(ConfiguracionAgenda configuracion);

  Future<ConfiguracionAgenda> getHorarioAtencion();

  Future<void> saveModoOscuro(bool esModoOscuro);

  Future<bool> getModoOscuro();
}
