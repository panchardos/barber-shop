import 'package:sqflite/sqflite.dart';
import '../../domain/entities/turno.dart';
import '../../domain/ports/turno_repository.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../models/turno_model.dart';

class SqfliteTurnoAdapter implements TurnoRepository {
  final Database _db;
  final List<Turno> _cache = [];

  SqfliteTurnoAdapter(this._db);

  /// Carga inicial de SQLite a memoria (se ejecuta al arrancar la app en la Fase 4)
  Future<void> init() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query('turnos');
      _cache.clear();
      _cache.addAll(maps.map((map) => TurnoModel.fromSqflite(map).toEntity()));
    } catch (e) {
      throw PersistenceFailureException("Error al cargar turnos desde SQLite: $e");
    }
  }

  @override
  void save(Turno turno) {
    // 1. Actualizamos la memoria sincrónicamente
    final index = _cache.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      _cache[index] = turno;
    } else {
      _cache.add(turno);
    }

    // 2. Guardamos en SQLite en segundo plano
    final model = TurnoModel.fromEntity(turno);
    _db.insert(
      'turnos',
      model.toSqflite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ).catchError((e) {
      // Ignoramos o logueamos errores asíncronos de persistencia
    });
  }

  @override
  List<Turno> findByDate(String fechaYMD) {
    // Retorno sincrónico desde memoria
    final result = _cache.where((t) => t.fechaYMD == fechaYMD).toList();
    result.sort((a, b) => a.hora.compareTo(b.hora));
    return result;
  }

  @override
  bool existsAtTime(String fechaYMD, String hora) {
    // Consulta sincrónica en memoria
    return _cache.any((t) => t.fechaYMD == fechaYMD && t.hora == hora);
  }

  @override
  void delete(String id) {
    // 1. Borramos de memoria sincrónicamente
    final index = _cache.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }
    _cache.removeAt(index);

    // 2. Borramos en SQLite en segundo plano
    _db.delete('turnos', where: 'id = ?', whereArgs: [id]).catchError((e) {
      // Ignoramos o logueamos errores asíncronos
    });
  }

  /// Método para HU 8: Historial por teléfono de cliente
  @override
  List<Turno> findByClienteTelefono(String telefono) {
    final result = _cache.where((t) => t.cliente.telefono == telefono).toList();
    result.sort((a, b) => b.fechaYMD.compareTo(a.fechaYMD));
    return result;
  }
}