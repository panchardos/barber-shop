import '../../domain/entities/servicio.dart';
import '../../domain/ports/bloqueo_repository.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/services/disponibilidad_horaria_service.dart';

class ObtenerHorariosDisponiblesUseCase {
  final TurnoRepository _turnoRepository;
  final ConfiguracionRepository _configuracionRepository;
  final DisponibilidadHorariaService _disponibilidadService;
  final BloqueoRepository? _bloqueoRepository;

  ObtenerHorariosDisponiblesUseCase(
    this._turnoRepository,
    this._configuracionRepository,
    this._disponibilidadService, [
    this._bloqueoRepository,
  ]);

  Future<List<String>> execute({
    required String fechaYMD,
    required Servicio servicio,
    DateTime? ahora,
  }) async {
    if (fechaYMD.trim().isEmpty) {
      throw Exception("La fecha es obligatoria para calcular los horarios.");
    }

    final configuracion = await _configuracionRepository.getHorarioAtencion();
    final turnosDelDia = await _turnoRepository.findByDate(fechaYMD);
    final bloqueos =
        await _bloqueoRepository?.findByDate(fechaYMD) ?? const [];

    return _disponibilidadService.calcularHorariosDisponibles(
      fechaYMD: fechaYMD,
      configuracion: configuracion,
      servicio: servicio,
      turnosDelDia: turnosDelDia,
      bloqueos: bloqueos,
      ahora: ahora,
    );
  }
}
