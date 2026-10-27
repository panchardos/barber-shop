import 'dart:io';

import 'package:barber_shop/infrastructure/database/barberia_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('BarberiaDatabase', () {
    test('crea las tablas y siembra los servicios base', () async {
      final database = await BarberiaDatabase.open(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      addTearDown(database.close);

      final tablas = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final nombres = tablas.map((fila) => fila['name']).toList();

      expect(nombres, containsAll(<String>['turnos', 'servicios']));

      final servicios = await database.query('servicios');
      expect(servicios, hasLength(4));
    });

    test('migra de versión 1 a 2 conservando los turnos', () async {
      final directorio = await Directory.systemTemp.createTemp(
        'barberia_database_test_',
      );
      addTearDown(() async {
        if (await directorio.exists()) {
          await directorio.delete(recursive: true);
        }
      });

      final ruta = join(directorio.path, 'barberia.db');

      final version1 = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
          },
        ),
      );

      await version1.insert('turnos', {
        'id': 'TRN-LEGACY',
        'cliente_nombre': 'Cliente Histórico',
        'cliente_telefono': '2610000000',
        'servicio_id': '1',
        'servicio_nombre': 'Corte Tradicional',
        'servicio_duracion': 30,
        'servicio_precio': 5000.0,
        'fecha_ymd': '2026-10-20',
        'hora': '10:00',
      });
      await version1.close();

      final version2 = await BarberiaDatabase.open(
        factory: databaseFactoryFfi,
        path: ruta,
      );
      addTearDown(version2.close);

      final turnos = await version2.query('turnos');
      final servicios = await version2.query('servicios');

      expect(turnos, hasLength(1));
      expect(turnos.single['id'], 'TRN-LEGACY');
      expect(servicios, hasLength(4));
    });
  });
}
