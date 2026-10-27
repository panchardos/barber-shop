import '../../domain/entities/cliente.dart';
import '../../domain/entities/servicio.dart';
import '../../domain/entities/turno.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/services/disponibilidad_horaria_service.dart';

class AgendarTurnoUseCase {
  final TurnoRepository _turnoRepository;
  final ConfiguracionRepository _configuracionRepository;
  final DisponibilidadHorariaService _disponibilidadService;

  static int _secuencia = 0;

  AgendarTurnoUseCase(
    this._turnoRepository,
    this._configuracionRepository,
    this._disponibilidadService,
  );

  /// Ejecuta la acción de agendar un turno.
  /// Retorna el ID único del turno generado.
  Future<String> execute({
    required String nombreCliente,
    required String telefonoCliente,
    required Servicio servicioSeleccionado,
    required String fechaYMD,
    required String hora,
  }) async {
    if (nombreCliente.trim().isEmpty || telefonoCliente.trim().isEmpty) {
      throw Exception("Los datos personales del cliente son obligatorios.");
    }
    if (fechaYMD.trim().isEmpty || hora.trim().isEmpty) {
      throw Exception("La fecha y la hora son obligatorias.");
    }

    final configuracion = await _configuracionRepository.getHorarioAtencion();
    final turnosDelDia = _turnoRepository.findByDate(fechaYMD);

    final disponible = _disponibilidadService.estaDisponible(
      fechaYMD: fechaYMD,
      hora: hora,
      configuracion: configuracion,
      servicio: servicioSeleccionado,
      turnosDelDia: turnosDelDia,
    );

    if (!disponible) {
      throw HorarioNoDisponibleException(fechaYMD, hora);
    }

    _secuencia++;
    final idUnico = "TRN-${DateTime.now().microsecondsSinceEpoch}-$_secuencia";

    final nuevoTurno = Turno(
      id: idUnico,
      cliente: Cliente(nombre: nombreCliente, telefono: telefonoCliente),
      servicio: servicioSeleccionado,
      fechaYMD: fechaYMD,
      hora: hora,
    );

    await _turnoRepository.save(nuevoTurno);

    return idUnico;
  }
}
