import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/exceptions/domain_exceptions.dart';
import '../models/servicio_model.dart';

class BarberiaDatabase {
  static const String databaseName = 'barberia.db';
  static const int databaseVersion = 2;

  static Future<Database> open() async {
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = join(databasesPath, databaseName);

      return await openDatabase(
        dbPath,
        version: databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw PersistenceFailureException(
        "No se pudo abrir la base de datos local: $e",
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTurnosTable(db);
    await _createServiciosTable(db);
    await _seedServicios(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createServiciosTable(db);
      await _seedServicios(db);
    }
  }

  static Future<void> _createTurnosTable(Database db) async {
    await db.execute('''
      CREATE TABLE turnos (
        id TEXT PRIMARY KEY,
        cliente_nombre TEXT NOT NULL,
        cliente_telefono TEXT NOT NULL,
        servicio_id TEXT NOT NULL,
        servicio_nombre TEXT NOT NULL,
        servicio_duracion INTEGER NOT NULL,
        servicio_precio REAL NOT NULL,
        fecha_ymd TEXT NOT NULL,
        hora TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createServiciosTable(Database db) async {
    await db.execute('''
      CREATE TABLE servicios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        duracion_minutos INTEGER NOT NULL,
        precio REAL NOT NULL
      )
    ''');
  }

  static Future<void> _seedServicios(Database db) async {
    const serviciosBase = [
      ServicioModel(
        id: '1',
        nombre: 'Corte Tradicional',
        duracionMinutos: 30,
        precio: 5000.0,
      ),
      ServicioModel(
        id: '2',
        nombre: 'Arreglo de Barba',
        duracionMinutos: 30,
        precio: 3000.0,
      ),
      ServicioModel(
        id: '3',
        nombre: 'Corte + Barba',
        duracionMinutos: 45,
        precio: 7500.0,
      ),
      ServicioModel(
        id: '4',
        nombre: 'Perfilado de Cejas',
        duracionMinutos: 15,
        precio: 2000.0,
      ),
    ];

    for (final servicio in serviciosBase) {
      await db.insert(
        'servicios',
        servicio.toSqflite(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
