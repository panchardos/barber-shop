import '../../domain/entities/servicio.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/services/disponibilidad_horaria_service.dart';

class ObtenerHorariosDisponiblesUseCase {
  final TurnoRepository _turnoRepository;
  final ConfiguracionRepository _configuracionRepository;
  final DisponibilidadHorariaService _disponibilidadService;

  ObtenerHorariosDisponiblesUseCase(
    this._turnoRepository,
    this._configuracionRepository,
    this._disponibilidadService,
  );

  Future<List<String>> execute({
    required String fechaYMD,
    required Servicio servicio,
    DateTime? ahora,
  }) async {
    if (fechaYMD.trim().isEmpty) {
      throw Exception("La fecha es obligatoria para calcular los horarios.");
    }

    final configuracion = await _configuracionRepository.getHorarioAtencion();
    final turnosDelDia = _turnoRepository.findByDate(fechaYMD);

    return _disponibilidadService.calcularHorariosDisponibles(
      fechaYMD: fechaYMD,
      configuracion: configuracion,
      servicio: servicio,
      turnosDelDia: turnosDelDia,
      ahora: ahora,
    );
  }
}
