import '../../domain/entities/servicio.dart';
import '../../domain/ports/bloqueo_repository.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/services/disponibilidad_horaria_service.dart';

class ValidarDisponibilidadHorariaUseCase {
  final TurnoRepository _turnoRepository;
  final ConfiguracionRepository _configuracionRepository;
  final DisponibilidadHorariaService _disponibilidadService;
  final BloqueoRepository? _bloqueoRepository;

  ValidarDisponibilidadHorariaUseCase(
    this._turnoRepository,
    this._configuracionRepository,
    this._disponibilidadService, [
    this._bloqueoRepository,
  ]);

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
    final turnosDelDia = await _turnoRepository.findByDate(fechaYMD);
    final bloqueos =
        await _bloqueoRepository?.findByDate(fechaYMD) ?? const [];

    return _disponibilidadService.estaDisponible(
      fechaYMD: fechaYMD,
      hora: hora,
      configuracion: configuracion,
      servicio: servicio,
      turnosDelDia: turnosDelDia,
      bloqueos: bloqueos,
    );
  }
}
