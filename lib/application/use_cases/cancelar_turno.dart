import '../../domain/ports/turno_repository.dart';

class CancelarTurnoUseCase {
  final TurnoRepository _turnoRepository;

  CancelarTurnoUseCase(this._turnoRepository);

  void execute(String idTurno) {
    if (idTurno.trim().isEmpty) {
      throw Exception("El ID del turno es inválido.");
    }
    _turnoRepository.delete(idTurno);
  }
}