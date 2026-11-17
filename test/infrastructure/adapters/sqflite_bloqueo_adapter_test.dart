import 'package:barber_shop/domain/entities/bloqueo.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/infrastructure/adapters/sqflite_bloqueo_adapter.dart';
import 'package:barber_shop/infrastructure/database/barberia_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqfliteBloqueoAdapter adapter;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    database = await BarberiaDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    adapter = SqfliteBloqueoAdapter(database);
  });

  tearDown(() async {
    await database.close();
  });

  const fecha = '2030-01-15';

  test('guarda y recupera bloqueos por fecha', () async {
    await adapter.save(
      const Bloqueo(
        id: 'BLQ-1',
        fechaYMD: fecha,
        horaInicio: '10:00',
        horaFin: '11:00',
        motivo: 'Trámite',
      ),
    );
    await adapter.save(
      const Bloqueo(id: 'BLQ-2', fechaYMD: fecha, todoElDia: true),
    );

    final bloqueos = await adapter.findByDate(fecha);

    expect(bloqueos, hasLength(2));
    expect(bloqueos.first.todoElDia, isTrue);
    expect(bloqueos.last.motivo, 'Trámite');
  });

  test('elimina un bloqueo existente', () async {
    await adapter.save(
      const Bloqueo(id: 'BLQ-1', fechaYMD: fecha, todoElDia: true),
    );

    await adapter.delete('BLQ-1');

    expect(await adapter.findByDate(fecha), isEmpty);
    await expectLater(
      adapter.delete('BLQ-1'),
      throwsA(isA<BloqueoNotFoundException>()),
    );
  });
}
