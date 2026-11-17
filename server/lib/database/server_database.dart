import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ServerDatabase {
  final Database _db;

  ServerDatabase._(this._db);

  static Future<ServerDatabase> open({
    String? path,
    DatabaseFactory? factory,
  }) async {
    sqfliteFfiInit();
    final dbFactory = factory ?? databaseFactoryFfi;
    final dbPath = path ?? 'data/demo.db';

    if (dbPath != inMemoryDatabasePath) {
      Directory(p.dirname(dbPath)).createSync(recursive: true);
    }

    final database = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createSchema(db);
          await _seed(db);
        },
      ),
    );

    final result = ServerDatabase._(database);
    await result._seedIfEmpty();
    return result;
  }

  Future<void> close() => _db.close();

  Future<void> _seedIfEmpty() async {
    final services = await _db.query('services', limit: 1);
    final config = await _db.query('config', where: 'id = 1', limit: 1);
    if (services.isEmpty || config.isEmpty) {
      await _db.transaction((txn) async {
        await _seed(txn);
      });
    }
  }

  static Future<void> _createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        duracion_minutos INTEGER NOT NULL,
        precio REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE config (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        apertura TEXT NOT NULL,
        cierre TEXT NOT NULL,
        duracion_bloque_minutos INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        cliente_nombre TEXT NOT NULL,
        cliente_telefono TEXT NOT NULL,
        servicio_id TEXT NOT NULL,
        servicio_nombre TEXT NOT NULL,
        servicio_duracion INTEGER NOT NULL,
        servicio_precio REAL NOT NULL,
        fecha_ymd TEXT NOT NULL,
        hora TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'reservado',
        created_at TEXT NOT NULL,
        canceled_at TEXT
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_appointments_activos
      ON appointments (fecha_ymd, hora)
      WHERE estado = 'reservado'
    ''');
  }

  static Future<void> _seed(DatabaseExecutor db) async {
    final now = DateTime.now().toUtc().toIso8601String();

    const services = [
      ('1', 'Corte Tradicional', 30, 5000.0),
      ('2', 'Arreglo de Barba', 30, 3000.0),
      ('3', 'Corte + Barba', 45, 7500.0),
      ('4', 'Perfilado de Cejas', 15, 2000.0),
    ];

    for (final service in services) {
      await db.insert('services', {
        'id': service.$1,
        'nombre': service.$2,
        'duracion_minutos': service.$3,
        'precio': service.$4,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await db.insert('config', {
      'id': 1,
      'apertura': '09:00',
      'cierre': '20:00',
      'duracion_bloque_minutos': 30,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> listServices() {
    return _db.query('services', orderBy: 'id ASC');
  }

  Future<Map<String, dynamic>?> findService(String id) async {
    final rows = await _db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertService({
    required String id,
    required String nombre,
    required int duracionMinutos,
    required double precio,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.insert('services', {
      'id': id,
      'nombre': nombre,
      'duracion_minutos': duracionMinutos,
      'precio': precio,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<bool> updateServicePrice(String id, double precio) async {
    final count = await _db.update(
      'services',
      {
        'precio': precio,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<Map<String, dynamic>> getConfig() async {
    final rows = await _db.query('config', where: 'id = 1', limit: 1);
    if (rows.isEmpty) {
      throw StateError('No hay configuración cargada.');
    }
    return rows.first;
  }

  Future<void> updateConfig({
    required String apertura,
    required String cierre,
    required int duracionBloqueMinutos,
  }) async {
    final count = await _db.update('config', {
      'apertura': apertura,
      'cierre': cierre,
      'duracion_bloque_minutos': duracionBloqueMinutos,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, where: 'id = 1');

    if (count == 0) {
      await _db.insert('config', {
        'id': 1,
        'apertura': apertura,
        'cierre': cierre,
        'duracion_bloque_minutos': duracionBloqueMinutos,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> appointmentsByDate(String fechaYMD) {
    return _db.query(
      'appointments',
      where: "fecha_ymd = ? AND estado = 'reservado'",
      whereArgs: [fechaYMD],
      orderBy: 'hora ASC',
    );
  }

  Future<List<Map<String, dynamic>>> occupiedByDate(String fechaYMD) {
    return _db.query(
      'appointments',
      columns: ['hora', 'servicio_duracion'],
      where: "fecha_ymd = ? AND estado = 'reservado'",
      whereArgs: [fechaYMD],
    );
  }

  Future<List<Map<String, dynamic>>> appointmentsByPhone(String telefono) {
    return _db.query(
      'appointments',
      where: "cliente_telefono = ? AND estado = 'reservado'",
      whereArgs: [telefono],
      orderBy: 'fecha_ymd DESC, hora DESC',
    );
  }

  Future<Map<String, dynamic>?> findAppointment(String id) async {
    final rows = await _db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertAppointment({
    required String id,
    required String clienteNombre,
    required String clienteTelefono,
    required String servicioId,
    required String servicioNombre,
    required int servicioDuracion,
    required double servicioPrecio,
    required String fechaYMD,
    required String hora,
  }) async {
    await _db.insert('appointments', {
      'id': id,
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'servicio_id': servicioId,
      'servicio_nombre': servicioNombre,
      'servicio_duracion': servicioDuracion,
      'servicio_precio': servicioPrecio,
      'fecha_ymd': fechaYMD,
      'hora': hora,
      'estado': 'reservado',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'canceled_at': null,
    });
  }

  Future<bool> cancelAppointment(String id) async {
    final count = await _db.update(
      'appointments',
      {
        'estado': 'cancelado',
        'canceled_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: "id = ? AND estado = 'reservado'",
      whereArgs: [id],
    );
    return count > 0;
  }

  Future<void> resetDemo() async {
    await _db.transaction((txn) async {
      await txn.delete('appointments');
      await txn.delete('services');
      await txn.delete('config');
      await _seed(txn);
    });
  }
}
