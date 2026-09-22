import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/exceptions/domain_exceptions.dart';

class InMemoryTurnoAdapter implements TurnoRepository {
  final List<Turno> _turnos = [];

  @override
  void save(Turno turno) {
    final index = _turnos.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      _turnos[index] = turno;
    } else {
      _turnos.add(turno);
    }
  }

  @override
  bool existsAtTime(String fechaYMD, String hora) {
    return _turnos.any((t) => t.fechaYMD == fechaYMD && t.hora == hora);
  }

  @override
  List<Turno> findByDate(String fechaYMD) {
    final result = _turnos.where((t) => t.fechaYMD == fechaYMD).toList();
    result.sort((a, b) => a.hora.compareTo(b.hora));
    return result;
  }

  @override
  void delete(String id) {
    final index = _turnos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }
    _turnos.removeAt(index);
  }

  @override
  List<Turno> findByClienteTelefono(String telefono) {
    final result = _turnos.where((t) => t.cliente.telefono == telefono).toList();
    result.sort((a, b) => b.fechaYMD.compareTo(a.fechaYMD));
    return result;
  }
}