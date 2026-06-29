import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';

class ObtenerTurnosPorDiaUseCase {
  final TurnoRepository _turnoRepository;

  ObtenerTurnosPorDiaUseCase(this._turnoRepository);

  List<Turno> execute(String fechaYMD) {
    final turnos = _turnoRepository.findByDate(fechaYMD);
    // Ordenamos por hora para que la agenda se vea bien cronológicamente
    turnos.sort((a, b) => a.hora.compareTo(b.hora));
    return turnos;
  }
}