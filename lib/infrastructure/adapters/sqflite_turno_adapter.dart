import 'package:sqflite/sqflite.dart';
import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../models/turno_model.dart';

class SqfliteTurnoAdapter implements TurnoRepository {
  final Database _db;
  final List<Turno> _cache = [];

  SqfliteTurnoAdapter(this._db);

  /// Carga inicial de SQLite a memoria (se ejecuta al arrancar la app).
  Future<void> init() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query('turnos');
      _cache
        ..clear()
        ..addAll(maps.map((map) => TurnoModel.fromSqflite(map).toEntity()));
    } catch (e) {
      throw PersistenceFailureException(
        "Error al cargar turnos desde SQLite: $e",
      );
    }
  }

  @override
  Future<void> save(Turno turno) async {
    final model = TurnoModel.fromEntity(turno);

    try {
      await _db.insert(
        'turnos',
        model.toSqflite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudo guardar el turno ${turno.id}: $e",
      );
    }

    final index = _cache.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      _cache[index] = turno;
    } else {
      _cache.add(turno);
    }
  }

  @override
  List<Turno> findByDate(String fechaYMD) {
    final result = _cache.where((t) => t.fechaYMD == fechaYMD).toList();
    result.sort((a, b) => a.hora.compareTo(b.hora));
    return result;
  }

  @override
  bool existsAtTime(String fechaYMD, String hora) {
    return _cache.any((t) => t.fechaYMD == fechaYMD && t.hora == hora);
  }

  @override
  Future<void> delete(String id) async {
    final index = _cache.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }

    try {
      await _db.delete('turnos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw PersistenceFailureException("No se pudo eliminar el turno $id: $e");
    }

    _cache.removeAt(index);
  }

  /// Método para HU 8: Historial por teléfono de cliente.
  @override
  List<Turno> findByClienteTelefono(String telefono) {
    final result = _cache.where((t) => t.cliente.telefono == telefono).toList();
    result.sort((a, b) {
      final porFecha = b.fechaYMD.compareTo(a.fechaYMD);
      if (porFecha != 0) return porFecha;
      return b.hora.compareTo(a.hora);
    });
    return result;
  }
}
