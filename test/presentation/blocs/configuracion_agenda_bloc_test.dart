import 'package:barber_shop/application/use_cases/configurar_agenda.dart';
import 'package:barber_shop/presentation/blocs/configuracion_agenda/configuracion_agenda_bloc.dart';
import 'package:barber_shop/presentation/blocs/configuracion_agenda/configuracion_agenda_event.dart';
import 'package:barber_shop/presentation/blocs/configuracion_agenda/configuracion_agenda_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ConfiguracionAgendaBloc', () {
    late FakeConfiguracionRepository repository;

    setUp(() {
      repository = FakeConfiguracionRepository();
    });

    ConfiguracionAgendaBloc crearBloc() {
      return ConfiguracionAgendaBloc(ConfigurarAgendaUseCase(repository));
    }

    blocTest<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
      'carga la configuración actual',
      build: crearBloc,
      act: (bloc) => bloc.add(const ConfiguracionAgendaCargada()),
      expect: () => [
        isA<ConfiguracionAgendaLoading>(),
        isA<ConfiguracionAgendaLoaded>()
            .having(
              (state) => state.configuracion.apertura,
              'apertura',
              '09:00',
            )
            .having(
              (state) => state.configuracion.duracionBloqueMinutos,
              'duración',
              30,
            ),
      ],
    );

    blocTest<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
      'guarda la configuración',
      build: crearBloc,
      seed: () =>
          ConfiguracionAgendaLoaded(configuracion: repository.configuracion),
      act: (bloc) => bloc.add(
        const ConfiguracionAgendaGuardada(
          apertura: '08:30',
          cierre: '19:00',
          duracionBloque: 45,
        ),
      ),
      expect: () => [
        isA<ConfiguracionAgendaLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<ConfiguracionAgendaLoaded>()
            .having(
              (state) => state.configuracion.apertura,
              'apertura',
              '08:30',
            )
            .having((state) => state.configuracion.cierre, 'cierre', '19:00')
            .having(
              (state) => state.configuracion.duracionBloqueMinutos,
              'duración',
              45,
            )
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
    );

    blocTest<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
      'informa error al guardar',
      build: () {
        repository.failOnSave = true;
        return crearBloc();
      },
      seed: () =>
          ConfiguracionAgendaLoaded(configuracion: repository.configuracion),
      act: (bloc) => bloc.add(
        const ConfiguracionAgendaGuardada(
          apertura: '08:30',
          cierre: '19:00',
          duracionBloque: 45,
        ),
      ),
      expect: () => [
        isA<ConfiguracionAgendaLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<ConfiguracionAgendaLoaded>().having(
          (state) => state.errorMessage,
          'error',
          isNotNull,
        ),
      ],
    );

    blocTest<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
      'limpia los mensajes',
      build: crearBloc,
      seed: () => ConfiguracionAgendaLoaded(
        configuracion: repository.configuracion,
        successMessage: 'Guardado',
        errorMessage: 'Error',
      ),
      act: (bloc) => bloc.add(const ConfiguracionAgendaMensajeLimpiado()),
      expect: () => [
        isA<ConfiguracionAgendaLoaded>()
            .having((state) => state.successMessage, 'success', isNull)
            .having((state) => state.errorMessage, 'error', isNull),
      ],
    );
  });
}
