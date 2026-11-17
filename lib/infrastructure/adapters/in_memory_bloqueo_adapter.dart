import '../../domain/entities/bloqueo.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/bloqueo_repository.dart';

class InMemoryBloqueoAdapter implements BloqueoRepository {
  final List<Bloqueo> _bloqueos = [];

  List<Bloqueo> get bloqueos => List.unmodifiable(_bloqueos);

  @override
  Future<void> save(Bloqueo bloqueo) async {
    final index = _bloqueos.indexWhere((b) => b.id == bloqueo.id);
    if (index >= 0) {
      _bloqueos[index] = bloqueo;
    } else {
      _bloqueos.add(bloqueo);
    }
  }

  @override
  Future<void> delete(String id) async {
    final index = _bloqueos.indexWhere((b) => b.id == id);
    if (index < 0) {
      throw BloqueoNotFoundException(id);
    }
    _bloqueos.removeAt(index);
  }

  @override
  Future<List<Bloqueo>> findByDate(String fechaYMD) async {
    final result = _bloqueos
        .where((bloqueo) => bloqueo.fechaYMD == fechaYMD)
        .toList();
    result.sort((a, b) {
      if (a.todoElDia != b.todoElDia) return a.todoElDia ? -1 : 1;
      return (a.horaInicio ?? '').compareTo(b.horaInicio ?? '');
    });
    return result;
  }
}
