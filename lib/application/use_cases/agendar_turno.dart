import '../../domain/entities/cliente.dart';
import '../../domain/entities/servicio.dart';
import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';

class AgendarTurnoUseCase {
  // Inyectamos el puerto (la interfaz abstracta) a través del constructor
  final TurnoRepository _turnoRepository;

  AgendarTurnoUseCase(this._turnoRepository);

  /// Ejecuta la acción de agendar un turno.
  /// Retorna el ID único del turno generado.
  String execute({
    required String nombreCliente,
    required String telefonoCliente,
    required Servicio servicioSeleccionado,
    required String fechaYMD,
    required String hora,
  }) {
    // 1. REGLA DE NEGOCIO: Validar que los datos del cliente no vengan vacíos
    if (nombreCliente.trim().isEmpty || telefonoCliente.trim().isEmpty) {
      throw Exception("Los datos personales del cliente son obligatorios.");
    }

    // 2. REGLA DE NEGOCIO CRÍTICA: Validar colisión de horarios usando el Puerto
    if (_turnoRepository.existsAtTime(fechaYMD, hora)) {
      throw Exception("Lo sentimos, este horario ya se encuentra reservado.");
    }

    // 3. Generar un ID único provisorio para el MVP
    final idUnico = "TRN-${DateTime.now().microsecondsSinceEpoch}";

    // 4. Mapear y construir la Entidad de Dominio
    final nuevoTurno = Turno(
      id: idUnico,
      cliente: Cliente(nombre: nombreCliente, telefono: telefonoCliente),
      servicio: servicioSeleccionado,
      fechaYMD: fechaYMD,
      hora: hora,
    );

    // 5. Persistir el turno a través del Puerto
    _turnoRepository.save(nuevoTurno);

    return idUnico;
  }
}