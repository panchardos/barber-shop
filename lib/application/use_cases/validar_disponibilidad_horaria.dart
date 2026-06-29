import '../../domain/ports/turno_repository.dart';

class ValidarDisponibilidadHorariaUseCase {
  final TurnoRepository _turnoRepository;

  ValidarDisponibilidadHorariaUseCase(this._turnoRepository);

  /// Retorna [true] si el horario está disponible (libre), [false] si ya está ocupado.
  bool execute(String fechaYMD, String hora) {
    if (fechaYMD.trim().isEmpty || hora.trim().isEmpty) {
      throw Exception("La fecha y la hora son obligatorias para validar disponibilidad.");
    }
    
    // Invertimos el resultado de existsAtTime: si NO existe, entonces ESTÁ disponible.
    final estaOcupado = _turnoRepository.existsAtTime(fechaYMD, hora);
    return !estaOcupado;
  }
}