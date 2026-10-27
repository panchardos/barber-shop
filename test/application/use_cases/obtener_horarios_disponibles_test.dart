import 'package:barber_shop/application/use_cases/obtener_horarios_disponibles.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ObtenerHorariosDisponiblesUseCase', () {
    late FakeTurnoRepository turnoRepository;
    late FakeConfiguracionRepository configuracionRepository;
    late ObtenerHorariosDisponiblesUseCase useCase;
    late Servicio servicio;

    const fecha = '2030-01-15';
    final ahora = DateTime(2030, 1, 15, 8);

    setUp(() {
      turnoRepository = FakeTurnoRepository();
      configuracionRepository = FakeConfiguracionRepository();
      useCase = ObtenerHorariosDisponiblesUseCase(
        turnoRepository,
        configuracionRepository,
        const DisponibilidadHorariaService(),
      );
      servicio = Servicio(
        id: '1',
        nombre: 'Corte Tradicional',
        duracionMinutos: 30,
        precio: 5000,
      );
      configuracionRepository.configuracion = const ConfiguracionAgenda(
        apertura: '09:00',
        cierre: '12:00',
        duracionBloqueMinutos: 30,
      );
    });

    test('retorna los horarios disponibles del día', () async {
      final horarios = await useCase.execute(
        fechaYMD: fecha,
        servicio: servicio,
        ahora: ahora,
      );

      expect(horarios, ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30']);
    });

    test('excluye los horarios ocupados', () async {
      await turnoRepository.save(
        Turno(
          id: 'TRN-1',
          cliente: Cliente(nombre: 'Ana Pérez', telefono: '2611234567'),
          servicio: servicio,
          fechaYMD: fecha,
          hora: '10:00',
        ),
      );

      final horarios = await useCase.execute(
        fechaYMD: fecha,
        servicio: servicio,
        ahora: ahora,
      );

      expect(horarios, isNot(contains('10:00')));
      expect(horarios, contains('10:30'));
    });

    test('refleja los cambios de configuración', () async {
      configuracionRepository.configuracion = const ConfiguracionAgenda(
        apertura: '10:00',
        cierre: '11:00',
        duracionBloqueMinutos: 30,
      );

      final horarios = await useCase.execute(
        fechaYMD: fecha,
        servicio: servicio,
        ahora: ahora,
      );

      expect(horarios, ['10:00', '10:30']);
    });

    test('rechaza una fecha vacía', () async {
      await expectLater(
        useCase.execute(fechaYMD: '', servicio: servicio),
        throwsA(isA<Exception>()),
      );
    });
  });
}
