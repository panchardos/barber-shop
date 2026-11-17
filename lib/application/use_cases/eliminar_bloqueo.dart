import '../../domain/ports/bloqueo_repository.dart';

class EliminarBloqueoUseCase {
  final BloqueoRepository _bloqueoRepository;

  EliminarBloqueoUseCase(this._bloqueoRepository);

  Future<void> execute(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('El ID del bloqueo es inválido.');
    }
    await _bloqueoRepository.delete(id);
  }
}
