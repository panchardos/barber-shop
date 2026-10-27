import 'package:barber_shop/application/use_cases/agendar_turno.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('AgendarTurnoUseCase', () {
    late FakeTurnoRepository repository;
    late FakeConfiguracionRepository configuracionRepository;
    late AgendarTurnoUseCase useCase;
    late Servicio servicio;

    const fecha = '2030-01-15';

    setUp(() {
      repository = FakeTurnoRepository();
      configuracionRepository = FakeConfiguracionRepository();
      useCase = AgendarTurnoUseCase(
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

    test('agenda un turno válido y lo persiste', () async {
      final id = await useCase.execute(
        nombreCliente: 'Ana Pérez',
        telefonoCliente: '2611234567',
        servicioSeleccionado: servicio,
        fechaYMD: fecha,
        hora: '10:30',
      );

      expect(id, isNotEmpty);
      expect(repository.turnos, hasLength(1));
      expect(repository.turnos.single.id, id);
      expect(repository.turnos.single.cliente.nombre, 'Ana Pérez');
      expect(repository.turnos.single.servicio.nombre, 'Corte Tradicional');
    });

    test('genera identificadores distintos para turnos distintos', () async {
      final primerId = await useCase.execute(
        nombreCliente: 'Ana Pérez',
        telefonoCliente: '2611234567',
        servicioSeleccionado: servicio,
        fechaYMD: fecha,
        hora: '10:30',
      );

      final segundoId = await useCase.execute(
        nombreCliente: 'Luis Gómez',
        telefonoCliente: '2617654321',
        servicioSeleccionado: servicio,
        fechaYMD: fecha,
        hora: '11:00',
      );

      expect(primerId, isNot(segundoId));
      expect(repository.turnos, hasLength(2));
    });

    test('rechaza datos personales vacíos', () async {
      await expectLater(
        useCase.execute(
          nombreCliente: '   ',
          telefonoCliente: '2611234567',
          servicioSeleccionado: servicio,
          fechaYMD: fecha,
          hora: '10:30',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rechaza un horario ya ocupado', () async {
      await useCase.execute(
        nombreCliente: 'Ana Pérez',
        telefonoCliente: '2611234567',
        servicioSeleccionado: servicio,
        fechaYMD: fecha,
        hora: '10:30',
      );

      await expectLater(
        useCase.execute(
          nombreCliente: 'Luis Gómez',
          telefonoCliente: '2617654321',
          servicioSeleccionado: servicio,
          fechaYMD: fecha,
          hora: '10:30',
        ),
        throwsA(isA<HorarioNoDisponibleException>()),
      );
      expect(repository.turnos, hasLength(1));
    });

    test('rechaza un horario fuera de la configuración', () async {
      await expectLater(
        useCase.execute(
          nombreCliente: 'Ana Pérez',
          telefonoCliente: '2611234567',
          servicioSeleccionado: servicio,
          fechaYMD: fecha,
          hora: '08:00',
        ),
        throwsA(isA<HorarioNoDisponibleException>()),
      );
      expect(repository.turnos, isEmpty);
    });

    test(
      'rechaza superposición parcial según la duración del servicio',
      () async {
        await repository.save(
          Turno(
            id: 'TRN-EXISTENTE',
            cliente: Cliente(nombre: 'Cliente previo', telefono: '2610000000'),
            servicio: Servicio(
              id: '2',
              nombre: 'Corte + Barba',
              duracionMinutos: 45,
              precio: 7500,
            ),
            fechaYMD: fecha,
            hora: '10:00',
          ),
        );

        await expectLater(
          useCase.execute(
            nombreCliente: 'Ana Pérez',
            telefonoCliente: '2611234567',
            servicioSeleccionado: servicio,
            fechaYMD: fecha,
            hora: '10:30',
          ),
          throwsA(isA<HorarioNoDisponibleException>()),
        );
      },
    );

    test('acepta un horario adyacente sin superposición', () async {
      await repository.save(
        Turno(
          id: 'TRN-EXISTENTE',
          cliente: Cliente(nombre: 'Cliente previo', telefono: '2610000000'),
          servicio: servicio,
          fechaYMD: fecha,
          hora: '10:00',
        ),
      );

      final id = await useCase.execute(
        nombreCliente: 'Ana Pérez',
        telefonoCliente: '2611234567',
        servicioSeleccionado: servicio,
        fechaYMD: fecha,
        hora: '10:30',
      );

      expect(id, isNotEmpty);
      expect(repository.turnos, hasLength(2));
    });

    test('propaga errores de persistencia', () async {
      repository.failOnSave = true;

      await expectLater(
        useCase.execute(
          nombreCliente: 'Ana Pérez',
          telefonoCliente: '2611234567',
          servicioSeleccionado: servicio,
          fechaYMD: fecha,
          hora: '10:30',
        ),
        throwsA(isA<PersistenceFailureException>()),
      );
      expect(repository.turnos, isEmpty);
    });
  });
}
