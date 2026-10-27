import 'package:sqflite/sqflite.dart';

import '../../domain/entities/servicio.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/servicio_repository.dart';
import '../models/servicio_model.dart';

class SqfliteServicioAdapter implements ServicioRepository {
  final Database _db;
  final List<Servicio> _cache = [];

  SqfliteServicioAdapter(this._db);

  Future<void> init() async {
    try {
      final maps = await _db.query('servicios');
      _cache
        ..clear()
        ..addAll(maps.map((map) => ServicioModel.fromSqflite(map).toEntity()));
    } catch (e) {
      throw PersistenceFailureException(
        "Error al cargar servicios desde SQLite: $e",
      );
    }
  }

  @override
  List<Servicio> findAll() {
    return List.unmodifiable(_cache);
  }

  @override
  Servicio? findById(String id) {
    for (final servicio in _cache) {
      if (servicio.id == id) {
        return servicio;
      }
    }
    return null;
  }

  @override
  Future<void> save(Servicio servicio) async {
    final model = ServicioModel.fromEntity(servicio);

    try {
      await _db.insert(
        'servicios',
        model.toSqflite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudo guardar el servicio ${servicio.id}: $e",
      );
    }

    final index = _cache.indexWhere((s) => s.id == servicio.id);
    if (index >= 0) {
      _cache[index] = servicio;
    } else {
      _cache.add(servicio);
    }
  }

  @override
  Future<void> updatePrecio(String id, double nuevoPrecio) async {
    final index = _cache.indexWhere((s) => s.id == id);
    if (index < 0) {
      throw ServicioNotFoundException(id);
    }

    final servicioActual = _cache[index];
    final servicioActualizado = Servicio(
      id: servicioActual.id,
      nombre: servicioActual.nombre,
      duracionMinutos: servicioActual.duracionMinutos,
      precio: nuevoPrecio,
    );

    late int filasAfectadas;
    try {
      filasAfectadas = await _db.update(
        'servicios',
        ServicioModel.fromEntity(servicioActualizado).toSqflite(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudo actualizar el precio del servicio $id: $e",
      );
    }

    if (filasAfectadas == 0) {
      throw ServicioNotFoundException(id);
    }

    _cache[index] = servicioActualizado;
  }
}
