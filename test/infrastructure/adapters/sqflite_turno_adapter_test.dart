import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/infrastructure/adapters/sqflite_turno_adapter.dart';
import 'package:barber_shop/infrastructure/database/barberia_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqfliteTurnoAdapter adapter;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    database = await BarberiaDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    adapter = SqfliteTurnoAdapter(database);
    await adapter.init();
  });

  tearDown(() async {
    try {
      await database.close();
    } catch (_) {
      // La base pudo haberse cerrado dentro de un test de error.
    }
  });

  Turno crearTurno({
    String id = 'TRN-1',
    String telefono = '2611234567',
    String fecha = '2026-10-26',
    String hora = '10:30',
  }) {
    return Turno(
      id: id,
      cliente: Cliente(nombre: 'Ana Pérez', telefono: telefono),
      servicio: Servicio(
        id: '1',
        nombre: 'Corte Tradicional',
        duracionMinutos: 30,
        precio: 5000,
      ),
      fechaYMD: fecha,
      hora: hora,
    );
  }

  group('SqfliteTurnoAdapter', () {
    test('guarda un turno y lo recupera por fecha', () async {
      final turno = crearTurno();
      await adapter.save(turno);

      final turnos = await adapter.findByDate('2026-10-26');

      expect(turnos, hasLength(1));
      expect(turnos.single.id, turno.id);
      expect(turnos.single.cliente.telefono, turno.cliente.telefono);
    });

    test('detecta un horario ocupado', () async {
      await adapter.save(crearTurno());

      expect(await adapter.existsAtTime('2026-10-26', '10:30'), isTrue);
      expect(await adapter.existsAtTime('2026-10-26', '11:00'), isFalse);
    });

    test('ordena el historial por fecha y hora descendente', () async {
      await adapter.save(
        crearTurno(id: 'TRN-1', fecha: '2026-10-24', hora: '09:00'),
      );
      await adapter.save(
        crearTurno(id: 'TRN-2', fecha: '2026-10-26', hora: '09:00'),
      );
      await adapter.save(
        crearTurno(id: 'TRN-3', fecha: '2026-10-26', hora: '11:00'),
      );

      final historial = await adapter.findByClienteTelefono('2611234567');

      expect(historial.map((t) => t.id), ['TRN-3', 'TRN-2', 'TRN-1']);
    });

    test('carga los turnos existentes al inicializar', () async {
      await adapter.save(crearTurno(id: 'TRN-1'));

      final nuevoAdapter = SqfliteTurnoAdapter(database);
      await nuevoAdapter.init();

      expect(await nuevoAdapter.findByDate('2026-10-26'), hasLength(1));
    });

    test('cancela un turno y conserva el registro en el historial', () async {
      await adapter.save(crearTurno());

      await adapter.cancelar('TRN-1');

      expect(await adapter.findByDate('2026-10-26'), isEmpty);
      expect(await adapter.existsAtTime('2026-10-26', '10:30'), isFalse);

      final historial = await adapter.findByClienteTelefono('2611234567');
      expect(historial, hasLength(1));
      expect(historial.single.estaCancelado, isTrue);
    });

    test('informa cuando el turno a cancelar no existe', () async {
      await expectLater(
        adapter.cancelar('TRN-INEXISTENTE'),
        throwsA(isA<TurnoNotFoundException>()),
      );
    });

    test('traduce errores técnicos al guardar', () async {
      await database.close();

      await expectLater(
        adapter.save(crearTurno(id: 'TRN-2')),
        throwsA(isA<PersistenceFailureException>()),
      );
    });

    test('traduce errores técnicos al cancelar', () async {
      await adapter.save(crearTurno());
      await database.close();

      await expectLater(
        adapter.cancelar('TRN-1'),
        throwsA(isA<PersistenceFailureException>()),
      );
    });
  });
}
