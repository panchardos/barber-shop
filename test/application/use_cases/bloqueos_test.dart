import 'package:barber_shop/application/use_cases/crear_bloqueo.dart';
import 'package:barber_shop/application/use_cases/eliminar_bloqueo.dart';
import 'package:barber_shop/application/use_cases/obtener_bloqueos_por_dia.dart';
import 'package:barber_shop/application/use_cases/obtener_horarios_disponibles.dart';
import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('Bloqueos', () {
    late FakeBloqueoRepository repository;
    late FakeTurnoRepository turnoRepository;
    late FakeConfiguracionRepository configuracionRepository;
    late CrearBloqueoUseCase crear;
    late EliminarBloqueoUseCase eliminar;
    late ObtenerBloqueosPorDiaUseCase obtener;
    late ObtenerHorariosDisponiblesUseCase horarios;

    const fecha = '2030-01-15';
    final ahora = DateTime(2030, 1, 15, 8);

    setUp(() {
      repository = FakeBloqueoRepository();
      turnoRepository = FakeTurnoRepository();
      configuracionRepository = FakeConfiguracionRepository()
        ..configuracion = const ConfiguracionAgenda(
          apertura: '09:00',
          cierre: '12:00',
          duracionBloqueMinutos: 30,
        );
      crear = CrearBloqueoUseCase(repository);
      eliminar = EliminarBloqueoUseCase(repository);
      obtener = ObtenerBloqueosPorDiaUseCase(repository);
      horarios = ObtenerHorariosDisponiblesUseCase(
        turnoRepository,
        configuracionRepository,
        const DisponibilidadHorariaService(),
        repository,
      );
    });

    test('crea, lista y elimina un bloqueo por rango', () async {
      final id = await crear.execute(
        fechaYMD: fecha,
        todoElDia: false,
        horaInicio: '10:00',
        horaFin: '11:00',
        motivo: 'Trámite',
      );

      final bloqueos = await obtener.execute(fecha);
      expect(bloqueos, hasLength(1));
      expect(bloqueos.single.id, id);
      expect(bloqueos.single.motivo, 'Trámite');

      await eliminar.execute(id);
      expect(await obtener.execute(fecha), isEmpty);
    });

    test('rechaza un bloqueo por rango inválido', () async {
      await expectLater(
        crear.execute(
          fechaYMD: fecha,
          todoElDia: false,
          horaInicio: '11:00',
          horaFin: '10:00',
        ),
        throwsA(isA<BloqueoInvalidoException>()),
      );
      await expectLater(
        crear.execute(
          fechaYMD: fecha,
          todoElDia: false,
          horaInicio: '10:00',
        ),
        throwsA(isA<BloqueoInvalidoException>()),
      );
    });

    test('la disponibilidad excluye un bloqueo por rango', () async {
      await crear.execute(
        fechaYMD: fecha,
        todoElDia: false,
        horaInicio: '10:00',
        horaFin: '11:00',
      );

      final disponibles = await horarios.execute(
        fechaYMD: fecha,
        servicio: crearServicio(),
        ahora: ahora,
      );

      expect(disponibles, ['09:00', '09:30', '11:00', '11:30']);
    });

    test('la disponibilidad se vacía con un bloqueo de todo el día', () async {
      await crear.execute(fechaYMD: fecha, todoElDia: true);

      final disponibles = await horarios.execute(
        fechaYMD: fecha,
        servicio: crearServicio(),
        ahora: ahora,
      );

      expect(disponibles, isEmpty);
    });
  });
}
