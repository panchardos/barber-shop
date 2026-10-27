import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/infrastructure/adapters/sqflite_servicio_adapter.dart';
import 'package:barber_shop/infrastructure/database/barberia_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqfliteServicioAdapter adapter;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    database = await BarberiaDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    adapter = SqfliteServicioAdapter(database);
    await adapter.init();
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {
      // La base pudo haberse cerrado dentro de un test de error.
    }
  });

  group('SqfliteServicioAdapter', () {
    test('carga los servicios base sembrados por la base de datos', () {
      expect(adapter.findAll(), hasLength(4));
      expect(adapter.findById('1')!.nombre, 'Corte Tradicional');
    });

    test('guarda un servicio nuevo', () async {
      await adapter.save(
        Servicio(
          id: '5',
          nombre: 'Coloración',
          duracionMinutos: 60,
          precio: 12000,
        ),
      );

      expect(adapter.findAll(), hasLength(5));
      expect(adapter.findById('5')!.nombre, 'Coloración');
      expect(adapter.findById('5')!.precio, 12000);
    });

    test('actualiza el precio y lo persiste en SQLite', () async {
      await adapter.updatePrecio('1', 6500);

      expect(adapter.findById('1')!.precio, 6500);

      final filas = await database.query(
        'servicios',
        where: 'id = ?',
        whereArgs: ['1'],
      );
      expect((filas.single['precio'] as num).toDouble(), 6500);
    });

    test('informa cuando el servicio no existe', () async {
      await expectLater(
        adapter.updatePrecio('999', 6500),
        throwsA(isA<ServicioNotFoundException>()),
      );
    });

    test('traduce errores técnicos al guardar', () async {
      await database.close();

      await expectLater(
        adapter.save(
          Servicio(
            id: '6',
            nombre: 'Lavado',
            duracionMinutos: 15,
            precio: 1500,
          ),
        ),
        throwsA(isA<PersistenceFailureException>()),
      );
    });

    test('traduce errores técnicos al actualizar un precio', () async {
      await database.close();

      await expectLater(
        adapter.updatePrecio('1', 6500),
        throwsA(isA<PersistenceFailureException>()),
      );
    });
  });
}
