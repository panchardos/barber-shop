import '../../domain/entities/estado_turno.dart';
import '../../domain/entities/turno.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/turno_repository.dart';

class InMemoryTurnoAdapter implements TurnoRepository {
  final List<Turno> _turnos = [];

  @override
  Future<void> save(Turno turno) async {
    final index = _turnos.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      _turnos[index] = turno;
    } else {
      _turnos.add(turno);
    }
  }

  @override
  Future<bool> existsAtTime(String fechaYMD, String hora) async {
    return _turnos.any(
      (t) =>
          t.fechaYMD == fechaYMD &&
          t.hora == hora &&
          t.estado == EstadoTurno.reservado,
    );
  }

  @override
  Future<List<Turno>> findByDate(String fechaYMD) async {
    final result = _turnos
        .where(
          (t) =>
              t.fechaYMD == fechaYMD && t.estado == EstadoTurno.reservado,
        )
        .toList();
    result.sort((a, b) => a.hora.compareTo(b.hora));
    return result;
  }

  @override
  Future<void> cancelar(String id) async {
    final index = _turnos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }
    if (_turnos[index].estado == EstadoTurno.cancelado) {
      return;
    }
    _turnos[index] = _turnos[index].copyWith(estado: EstadoTurno.cancelado);
  }

  @override
  Future<List<Turno>> findByClienteTelefono(String telefono) async {
    final result = _turnos
        .where((t) => t.cliente.telefono == telefono)
        .toList();
    result.sort((a, b) {
      final porFecha = b.fechaYMD.compareTo(a.fechaYMD);
      if (porFecha != 0) return porFecha;
      return b.hora.compareTo(a.hora);
    });
    return result;
  }
}
