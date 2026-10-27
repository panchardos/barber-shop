import 'package:barber_shop/application/use_cases/validar_disponibilidad_horaria.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ValidarDisponibilidadHorariaUseCase', () {
    late FakeTurnoRepository repository;
    late ValidarDisponibilidadHorariaUseCase useCase;

    setUp(() {
      repository = FakeTurnoRepository();
      useCase = ValidarDisponibilidadHorariaUseCase(repository);
    });

    test('retorna true cuando el horario está libre', () {
      expect(useCase.execute('2026-10-26', '10:30'), isTrue);
    });

    test('retorna false cuando el horario está ocupado', () async {
      await repository.save(
        Turno(
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
        ),
      );

      expect(useCase.execute('2026-10-26', '10:30'), isFalse);
    });

    test('rechaza fecha u hora vacías', () {
      expect(() => useCase.execute('', '10:30'), throwsA(isA<Exception>()));
      expect(
        () => useCase.execute('2026-10-26', ''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
