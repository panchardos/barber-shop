import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/ports/configuracion_repository.dart';

class ConfigurarAgendaUseCase {
  final ConfiguracionRepository _configRepository;

  ConfigurarAgendaUseCase(this._configRepository);

  Future<void> guardarHorario({
    required String apertura,
    required String cierre,
    required int duracionBloque,
  }) async {
    await _configRepository.saveHorarioAtencion(
      ConfiguracionAgenda(
        apertura: apertura,
        cierre: cierre,
        duracionBloqueMinutos: duracionBloque,
      ),
    );
  }

  Future<ConfiguracionAgenda> obtenerHorario() async {
    return await _configRepository.getHorarioAtencion();
  }
}
