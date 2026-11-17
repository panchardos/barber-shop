import 'package:barber_shop/application/use_cases/crear_bloqueo.dart';
import 'package:barber_shop/application/use_cases/eliminar_bloqueo.dart';
import 'package:barber_shop/application/use_cases/obtener_bloqueos_por_dia.dart';
import 'package:barber_shop/presentation/blocs/bloqueos_admin/bloqueos_admin_bloc.dart';
import 'package:barber_shop/presentation/blocs/bloqueos_admin/bloqueos_admin_event.dart';
import 'package:barber_shop/presentation/blocs/bloqueos_admin/bloqueos_admin_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('BloqueosAdminBloc', () {
    late FakeBloqueoRepository repository;
    final fecha = DateTime(2030, 1, 15);

    setUp(() {
      repository = FakeBloqueoRepository();
    });

    BloqueosAdminBloc crearBloc() {
      return BloqueosAdminBloc(
        ObtenerBloqueosPorDiaUseCase(repository),
        CrearBloqueoUseCase(repository),
        EliminarBloqueoUseCase(repository),
      );
    }

    blocTest<BloqueosAdminBloc, BloqueosAdminState>(
      'carga los bloqueos de la fecha',
      build: crearBloc,
      act: (bloc) => bloc.add(BloqueosAdminCargados(fecha)),
      expect: () => [
        isA<BloqueosAdminLoading>(),
        isA<BloqueosAdminLoaded>()
            .having((state) => state.bloqueos, 'bloqueos', isEmpty)
            .having((state) => state.fecha, 'fecha', fecha),
      ],
    );

    blocTest<BloqueosAdminBloc, BloqueosAdminState>(
      'agrega un bloqueo y recarga',
      build: crearBloc,
      seed: () => BloqueosAdminLoaded(bloqueos: const [], fecha: fecha),
      act: (bloc) => bloc.add(
        BloqueoAgregado(
          fecha: fecha,
          todoElDia: false,
          horaInicio: '10:00',
          horaFin: '11:00',
        ),
      ),
      expect: () => [
        isA<BloqueosAdminLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<BloqueosAdminLoaded>()
            .having((state) => state.bloqueos, 'bloqueos', hasLength(1))
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
    );

    blocTest<BloqueosAdminBloc, BloqueosAdminState>(
      'elimina un bloqueo y recarga',
      build: () {
        repository.bloqueos.add(crearBloqueo());
        return crearBloc();
      },
      seed: () => BloqueosAdminLoaded(
        bloqueos: [crearBloqueo()],
        fecha: fecha,
      ),
      act: (bloc) => bloc.add(const BloqueoEliminado('BLQ-1')),
      expect: () => [
        isA<BloqueosAdminLoaded>().having(
          (state) => state.eliminando,
          'eliminando',
          true,
        ),
        isA<BloqueosAdminLoaded>()
            .having((state) => state.bloqueos, 'bloqueos', isEmpty)
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
    );
  });
}

