import '../../domain/entities/servicio.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/services/disponibilidad_horaria_service.dart';

class ValidarDisponibilidadHorariaUseCase {
  final TurnoRepository _turnoRepository;
  final ConfiguracionRepository _configuracionRepository;
  final DisponibilidadHorariaService _disponibilidadService;

  ValidarDisponibilidadHorariaUseCase(
    this._turnoRepository,
    this._configuracionRepository,
    this._disponibilidadService,
  );

  /// Retorna [true] si el horario está disponible para el servicio indicado.
  Future<bool> execute({
    required String fechaYMD,
    required String hora,
    required Servicio servicio,
  }) async {
    if (fechaYMD.trim().isEmpty || hora.trim().isEmpty) {
      throw Exception(
        "La fecha y la hora son obligatorias para validar disponibilidad.",
      );
    }

    final configuracion = await _configuracionRepository.getHorarioAtencion();
    final turnosDelDia = _turnoRepository.findByDate(fechaYMD);

    return _disponibilidadService.estaDisponible(
      fechaYMD: fechaYMD,
      hora: hora,
      configuracion: configuracion,
      servicio: servicio,
      turnosDelDia: turnosDelDia,
    );
  }
}
