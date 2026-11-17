import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/ports/configuracion_repository.dart';

class ObtenerConfiguracionAgendaUseCase {
  final ConfiguracionRepository _configuracionRepository;

  ObtenerConfiguracionAgendaUseCase(this._configuracionRepository);

  Future<ConfiguracionAgenda> execute() {
    return _configuracionRepository.getHorarioAtencion();
  }
}
