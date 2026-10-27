import 'package:barber_shop/application/use_cases/cancelar_turno.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('CancelarTurnoUseCase', () {
    late FakeTurnoRepository repository;
    late CancelarTurnoUseCase useCase;
    late Turno turno;

    setUp(() {
      turno = Turno(
        id: 'TRN-1',
        cliente: Cliente(nombre: 'Ana Pérez', telefono: '2611234567'),
        servicio: Servicio(
          id: '1',
          nombre: 'Corte Tradicional',
          duracionMinutos: 30,
          precio: 5000,
        ),
        fechaYMD: '2026-10-26',
        hora: '10:30',
      );
      repository = FakeTurnoRepository(turnos: [turno]);
      useCase = CancelarTurnoUseCase(repository);
    });

    test('cancela un turno existente', () async {
      await useCase.execute(turno.id);

      expect(repository.turnos, isEmpty);
    });

    test('rechaza un identificador vacío', () async {
      await expectLater(useCase.execute('   '), throwsA(isA<Exception>()));
      expect(repository.turnos, hasLength(1));
    });

    test('informa cuando el turno no existe', () async {
      await expectLater(
        useCase.execute('TRN-INEXISTENTE'),
        throwsA(isA<TurnoNotFoundException>()),
      );
    });

    test('propaga errores de persistencia', () async {
      repository.failOnDelete = true;

      await expectLater(
        useCase.execute(turno.id),
        throwsA(isA<PersistenceFailureException>()),
      );
      expect(repository.turnos, hasLength(1));
    });
  });
}
