import 'package:barber_shop/application/use_cases/validar_disponibilidad_horaria.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ValidarDisponibilidadHorariaUseCase', () {
    late FakeTurnoRepository repository;
    late FakeConfiguracionRepository configuracionRepository;
    late ValidarDisponibilidadHorariaUseCase useCase;
    late Servicio servicio;

    const fecha = '2030-01-15';

    setUp(() {
      repository = FakeTurnoRepository();
      configuracionRepository = FakeConfiguracionRepository();
      useCase = ValidarDisponibilidadHorariaUseCase(
        repository,
        configuracionRepository,
        const DisponibilidadHorariaService(),
      );
      servicio = Servicio(
        id: '1',
        nombre: 'Corte Tradicional',
        duracionMinutos: 30,
        precio: 5000,
      );
    });

    test('retorna true cuando el horario está libre', () async {
      final disponible = await useCase.execute(
        fechaYMD: fecha,
        hora: '10:30',
        servicio: servicio,
      );

      expect(disponible, isTrue);
    });

    test('retorna false cuando el horario está ocupado', () async {
      await repository.save(
        Turno(
          id: 'TRN-1',
          cliente: Cliente(nombre: 'Ana Pérez', telefono: '2611234567'),
          servicio: servicio,
          fechaYMD: fecha,
          hora: '10:30',
        ),
      );

      final disponible = await useCase.execute(
        fechaYMD: fecha,
        hora: '10:30',
        servicio: servicio,
      );

      expect(disponible, isFalse);
    });

    test('rechaza fecha u hora vacías', () async {
      await expectLater(
        useCase.execute(fechaYMD: '', hora: '10:30', servicio: servicio),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        useCase.execute(fechaYMD: fecha, hora: '', servicio: servicio),
        throwsA(isA<Exception>()),
      );
    });
  });
}
