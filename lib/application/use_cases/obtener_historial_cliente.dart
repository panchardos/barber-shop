import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';

class ObtenerHistorialClienteUseCase {
  final TurnoRepository _turnoRepository;

  ObtenerHistorialClienteUseCase(this._turnoRepository);

  List<Turno> execute(String telefono) {
    if (telefono.trim().isEmpty) {
      throw Exception("El número de teléfono es obligatorio para consultar el historial.");
    }
    return _turnoRepository.findByClienteTelefono(telefono);
  }
}