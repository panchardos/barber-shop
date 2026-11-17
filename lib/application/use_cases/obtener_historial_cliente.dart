import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';

class ObtenerHistorialClienteUseCase {
  final TurnoRepository _turnoRepository;

  ObtenerHistorialClienteUseCase(this._turnoRepository);

  Future<List<Turno>> execute(String telefono) async {
    if (telefono.trim().isEmpty) {
      throw Exception(
        "El número de teléfono es obligatorio para consultar el historial.",
      );
    }
    return await _turnoRepository.findByClienteTelefono(telefono);
  }
}
