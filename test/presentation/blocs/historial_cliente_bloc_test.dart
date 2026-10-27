import 'package:barber_shop/application/use_cases/obtener_historial_cliente.dart';
import 'package:barber_shop/presentation/blocs/historial_cliente/historial_cliente_bloc.dart';
import 'package:barber_shop/presentation/blocs/historial_cliente/historial_cliente_event.dart';
import 'package:barber_shop/presentation/blocs/historial_cliente/historial_cliente_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('HistorialClienteBloc', () {
    late FakeTurnoRepository repository;

    setUp(() {
      repository = FakeTurnoRepository(
        turnos: [
          crearTurno(id: 'TRN-1', telefono: '2611234567'),
          crearTurno(
            id: 'TRN-2',
            telefono: '2611234567',
            fechaYMD: '2030-01-16',
          ),
          crearTurno(id: 'TRN-3', telefono: '2617654321'),
        ],
      );
    });

    HistorialClienteBloc crearBloc() {
      return HistorialClienteBloc(ObtenerHistorialClienteUseCase(repository));
    }

    blocTest<HistorialClienteBloc, HistorialClienteState>(
      'busca el historial por teléfono',
      build: crearBloc,
      act: (bloc) => bloc.add(const HistorialClienteBuscado('2611234567')),
      expect: () => [
        isA<HistorialClienteLoading>(),
        isA<HistorialClienteLoaded>().having(
          (state) => state.turnos,
          'turnos',
          hasLength(2),
        ),
      ],
    );

    blocTest<HistorialClienteBloc, HistorialClienteState>(
      'retorna una lista vacía sin coincidencias',
      build: crearBloc,
      act: (bloc) => bloc.add(const HistorialClienteBuscado('0000000000')),
      expect: () => [
        isA<HistorialClienteLoading>(),
        isA<HistorialClienteLoaded>().having(
          (state) => state.turnos,
          'turnos',
          isEmpty,
        ),
      ],
    );

    blocTest<HistorialClienteBloc, HistorialClienteState>(
      'rechaza un teléfono vacío',
      build: crearBloc,
      act: (bloc) => bloc.add(const HistorialClienteBuscado('   ')),
      expect: () => [isA<HistorialClienteError>()],
    );
  });
}
