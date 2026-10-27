import '../../domain/ports/turno_repository.dart';

class CancelarTurnoUseCase {
  final TurnoRepository _turnoRepository;

  CancelarTurnoUseCase(this._turnoRepository);

  Future<void> execute(String idTurno) async {
    if (idTurno.trim().isEmpty) {
      throw Exception("El ID del turno es inválido.");
    }
    await _turnoRepository.delete(idTurno);
  }
}
