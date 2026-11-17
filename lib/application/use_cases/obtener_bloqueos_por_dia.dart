import '../../domain/entities/bloqueo.dart';
import '../../domain/ports/bloqueo_repository.dart';

class ObtenerBloqueosPorDiaUseCase {
  final BloqueoRepository _bloqueoRepository;

  ObtenerBloqueosPorDiaUseCase(this._bloqueoRepository);

  Future<List<Bloqueo>> execute(String fechaYMD) async {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(fechaYMD.trim())) {
      throw Exception('La fecha del bloqueo debe tener formato YYYY-MM-DD.');
    }
    return await _bloqueoRepository.findByDate(fechaYMD.trim());
  }
}
