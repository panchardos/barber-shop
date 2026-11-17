import 'package:sqflite/sqflite.dart';

import '../../domain/entities/bloqueo.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/bloqueo_repository.dart';
import '../models/bloqueo_model.dart';

class SqfliteBloqueoAdapter implements BloqueoRepository {
  final Database _db;

  SqfliteBloqueoAdapter(this._db);

  @override
  Future<void> save(Bloqueo bloqueo) async {
    try {
      await _db.insert(
        'bloqueos',
        BloqueoModel.fromEntity(bloqueo).toSqflite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudo guardar el bloqueo ${bloqueo.id}: $e",
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final filas = await _db.delete(
        'bloqueos',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (filas == 0) {
        throw BloqueoNotFoundException(id);
      }
    } catch (e) {
      if (e is BloqueoNotFoundException) rethrow;
      throw PersistenceFailureException(
        "No se pudo eliminar el bloqueo $id: $e",
      );
    }
  }

  @override
  Future<List<Bloqueo>> findByDate(String fechaYMD) async {
    try {
      final filas = await _db.query(
        'bloqueos',
        where: 'fecha_ymd = ?',
        whereArgs: [fechaYMD],
        orderBy: 'todo_el_dia DESC, hora_inicio ASC',
      );
      return filas.map((fila) => BloqueoModel.fromSqflite(fila).toEntity()).toList();
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudieron cargar los bloqueos de $fechaYMD: $e",
      );
    }
  }
}
