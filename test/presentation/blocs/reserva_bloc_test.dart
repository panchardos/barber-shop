import 'package:barber_shop/application/use_cases/agendar_turno.dart';
import 'package:barber_shop/application/use_cases/obtener_catalogo_servicios.dart';
import 'package:barber_shop/application/use_cases/obtener_horarios_disponibles.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:barber_shop/presentation/blocs/reserva/reserva_bloc.dart';
import 'package:barber_shop/presentation/blocs/reserva/reserva_event.dart';
import 'package:barber_shop/presentation/blocs/reserva/reserva_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('ReservaBloc', () {
    late FakeTurnoRepository turnoRepository;
    late FakeServicioRepository servicioRepository;
    late FakeConfiguracionRepository configuracionRepository;
    late List<Servicio> servicios;

    const disponibilidad = DisponibilidadHorariaService();
    final fecha = DateTime(2030, 1, 15);

    setUp(() {
      turnoRepository = FakeTurnoRepository();
      configuracionRepository = FakeConfiguracionRepository();
      servicios = [
        crearServicio(id: '1'),
        crearServicio(id: '2', nombre: 'Corte + Barba', duracionMinutos: 45),
      ];
      servicioRepository = FakeServicioRepository(servicios: servicios);
    });

    ReservaBloc crearBloc() {
      return ReservaBloc(
        ObtenerCatalogoServiciosUseCase(servicioRepository),
        ObtenerHorariosDisponiblesUseCase(
          turnoRepository,
          configuracionRepository,
          disponibilidad,
        ),
        AgendarTurnoUseCase(
          turnoRepository,
          configuracionRepository,
          disponibilidad,
        ),
      );
    }

    ReservaLoaded estadoCargado({String? hora = '10:00', Servicio? servicio}) {
      final seleccionado = servicio ?? servicios.first;
      return ReservaLoaded(
        servicios: servicios,
        servicioSeleccionado: seleccionado,
        fecha: fecha,
        horarios: const ['10:00', '10:30', '11:00'],
        horaSeleccionada: hora,
      );
    }

    blocTest<ReservaBloc, ReservaState>(
      'emite loading y loaded al iniciar',
      build: crearBloc,
      act: (bloc) => bloc.add(ReservaIniciada(fecha)),
      expect: () => [
        isA<ReservaLoading>(),
        isA<ReservaLoaded>()
            .having((state) => state.servicios.length, 'servicios', 2)
            .having((state) => state.servicioSeleccionado?.id, 'servicio', '1')
            .having((state) => state.horarios, 'horarios', contains('10:00')),
      ],
    );

    blocTest<ReservaBloc, ReservaState>(
      'emite error cuando no hay servicios',
      build: () => ReservaBloc(
        ObtenerCatalogoServiciosUseCase(FakeServicioRepository()),
        ObtenerHorariosDisponiblesUseCase(
          turnoRepository,
          configuracionRepository,
          disponibilidad,
        ),
        AgendarTurnoUseCase(
          turnoRepository,
          configuracionRepository,
          disponibilidad,
        ),
      ),
      act: (bloc) => bloc.add(ReservaIniciada(fecha)),
      expect: () => [isA<ReservaLoading>(), isA<ReservaError>()],
    );

    blocTest<ReservaBloc, ReservaState>(
      'recarga horarios al cambiar de servicio',
      build: crearBloc,
      seed: () => estadoCargado(),
      act: (bloc) => bloc.add(ReservaServicioSeleccionado(servicios[1])),
      expect: () => [
        isA<ReservaLoaded>().having(
          (state) => state.cargandoHorarios,
          'cargando',
          true,
        ),
        isA<ReservaLoaded>()
            .having((state) => state.servicioSeleccionado?.id, 'servicio', '2')
            .having((state) => state.cargandoHorarios, 'cargando', false),
      ],
    );

    blocTest<ReservaBloc, ReservaState>(
      'confirma una reserva válida',
      build: crearBloc,
      seed: () => estadoCargado(),
      act: (bloc) => bloc.add(
        const ReservaConfirmada(nombre: 'Ana Pérez', telefono: '2611234567'),
      ),
      expect: () => [
        isA<ReservaLoaded>().having(
          (state) => state.enviando,
          'enviando',
          true,
        ),
        isA<ReservaSuccess>().having((state) => state.hora, 'hora', '10:00'),
      ],
      verify: (_) {
        expect(turnoRepository.turnos, hasLength(1));
      },
    );

    blocTest<ReservaBloc, ReservaState>(
      'informa error cuando el horario ya está ocupado',
      build: () {
        turnoRepository.turnos.add(crearTurno(hora: '10:00'));
        return crearBloc();
      },
      seed: () => estadoCargado(),
      act: (bloc) => bloc.add(
        const ReservaConfirmada(nombre: 'Ana Pérez', telefono: '2611234567'),
      ),
      expect: () => [
        isA<ReservaLoaded>().having(
          (state) => state.enviando,
          'enviando',
          true,
        ),
        isA<ReservaLoaded>().having(
          (state) => state.errorMessage,
          'error',
          isNotNull,
        ),
      ],
    );

    blocTest<ReservaBloc, ReservaState>(
      'limpia el mensaje de error',
      build: crearBloc,
      seed: () => estadoCargado().copyWith(errorMessage: 'Error previo'),
      act: (bloc) => bloc.add(const ReservaMensajeLimpiado()),
      expect: () => [
        isA<ReservaLoaded>().having(
          (state) => state.errorMessage,
          'error',
          isNull,
        ),
      ],
    );
  });
}
