import 'package:barber_shop/application/use_cases/cancelar_turno.dart';
import 'package:barber_shop/application/use_cases/obtener_turnos_por_dia.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/presentation/blocs/agenda_admin/agenda_admin_bloc.dart';
import 'package:barber_shop/presentation/blocs/agenda_admin/agenda_admin_event.dart';
import 'package:barber_shop/presentation/blocs/agenda_admin/agenda_admin_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('AgendaAdminBloc', () {
    late FakeTurnoRepository repository;

    final fecha = DateTime(2030, 1, 15);

    setUp(() {
      repository = FakeTurnoRepository();
    });

    AgendaAdminBloc crearBloc() {
      return AgendaAdminBloc(
        ObtenerTurnosPorDiaUseCase(repository),
        CancelarTurnoUseCase(repository),
      );
    }

    AgendaAdminLoaded estadoCargado({List<Turno>? turnos}) {
      return AgendaAdminLoaded(turnos: turnos ?? const [], fecha: fecha);
    }

    blocTest<AgendaAdminBloc, AgendaAdminState>(
      'carga la agenda de una fecha',
      build: crearBloc,
      act: (bloc) => bloc.add(AgendaAdminCargada(fecha: fecha)),
      expect: () => [
        isA<AgendaAdminLoading>(),
        isA<AgendaAdminLoaded>()
            .having((state) => state.turnos, 'turnos', isEmpty)
            .having((state) => state.fecha, 'fecha', fecha),
      ],
    );

    blocTest<AgendaAdminBloc, AgendaAdminState>(
      'carga los turnos de la nueva fecha seleccionada',
      build: () {
        repository.turnos.add(crearTurno(id: 'TRN-2', fechaYMD: '2030-01-16'));
        return crearBloc();
      },
      seed: estadoCargado,
      act: (bloc) =>
          bloc.add(AgendaAdminFechaSeleccionada(DateTime(2030, 1, 16))),
      expect: () => [
        isA<AgendaAdminLoaded>().having(
          (state) => state.cargando,
          'cargando',
          true,
        ),
        isA<AgendaAdminLoaded>()
            .having((state) => state.turnos, 'turnos', hasLength(1))
            .having((state) => state.fecha, 'fecha', DateTime(2030, 1, 16)),
      ],
    );

    blocTest<AgendaAdminBloc, AgendaAdminState>(
      'cancela un turno y recarga la agenda',
      build: () {
        repository.turnos.add(crearTurno());
        return crearBloc();
      },
      seed: () => estadoCargado(turnos: [crearTurno()]),
      act: (bloc) => bloc.add(AgendaAdminTurnoCancelado(crearTurno())),
      expect: () => [
        isA<AgendaAdminLoaded>().having(
          (state) => state.cancelando,
          'cancelando',
          true,
        ),
        isA<AgendaAdminLoaded>()
            .having((state) => state.turnos, 'turnos', isEmpty)
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
    );

    blocTest<AgendaAdminBloc, AgendaAdminState>(
      'informa error al cancelar',
      build: () {
        repository
          ..turnos.add(crearTurno())
          ..failOnDelete = true;
        return crearBloc();
      },
      seed: () => estadoCargado(turnos: [crearTurno()]),
      act: (bloc) => bloc.add(AgendaAdminTurnoCancelado(crearTurno())),
      expect: () => [
        isA<AgendaAdminLoaded>().having(
          (state) => state.cancelando,
          'cancelando',
          true,
        ),
        isA<AgendaAdminLoaded>().having(
          (state) => state.errorMessage,
          'error',
          isNotNull,
        ),
      ],
    );

    blocTest<AgendaAdminBloc, AgendaAdminState>(
      'limpia los mensajes de la agenda',
      build: crearBloc,
      seed: () => AgendaAdminLoaded(
        turnos: const [],
        fecha: fecha,
        successMessage: 'Turno cancelado',
        errorMessage: 'Error previo',
      ),
      act: (bloc) => bloc.add(const AgendaAdminMensajeLimpiado()),
      expect: () => [
        isA<AgendaAdminLoaded>()
            .having((state) => state.successMessage, 'success', isNull)
            .having((state) => state.errorMessage, 'error', isNull),
      ],
    );
  });
}
