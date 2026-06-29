import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';

class InMemoryTurnoAdapter implements TurnoRepository {
  final List<Turno> _dbTurnos = [];

  @override
  void save(Turno turno) {
    _dbTurnos.add(turno);
    print(" [DB Turnos] Guardado: ${turno.id}");
  }

  @override
  bool existsAtTime(String fechaYMD, String hora) {
    return _dbTurnos.any((t) => t.fechaYMD == fechaYMD && t.hora == hora);
  }

  @override
  List<Turno> findByDate(String fechaYMD) {
    return _dbTurnos.where((t) => t.fechaYMD == fechaYMD).toList();
  }

  @override
  void delete(String id) {
    _dbTurnos.removeWhere((t) => t.id == id);
    print(" [DB Turnos] Eliminado: $id");
  }
}