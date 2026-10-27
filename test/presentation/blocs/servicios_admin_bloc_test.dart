import 'package:barber_shop/application/use_cases/actualizar_precio_servicio.dart';
import 'package:barber_shop/application/use_cases/crear_servicio.dart';
import 'package:barber_shop/application/use_cases/obtener_catalogo_servicios.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/presentation/blocs/servicios_admin/servicios_admin_bloc.dart';
import 'package:barber_shop/presentation/blocs/servicios_admin/servicios_admin_event.dart';
import 'package:barber_shop/presentation/blocs/servicios_admin/servicios_admin_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/test_entities.dart';

void main() {
  group('ServiciosAdminBloc', () {
    late FakeServicioRepository repository;

    setUp(() {
      repository = FakeServicioRepository(servicios: [crearServicio()]);
    });

    ServiciosAdminBloc crearBloc() {
      return ServiciosAdminBloc(
        ObtenerCatalogoServiciosUseCase(repository),
        CrearServicioUseCase(repository),
        ActualizarPrecioServicioUseCase(repository),
      );
    }

    ServiciosAdminLoaded estadoCargado({List<Servicio>? servicios}) {
      return ServiciosAdminLoaded(servicios: servicios ?? repository.servicios);
    }

    blocTest<ServiciosAdminBloc, ServiciosAdminState>(
      'carga el catálogo',
      build: crearBloc,
      act: (bloc) => bloc.add(const ServiciosAdminCargados()),
      expect: () => [
        isA<ServiciosAdminLoading>(),
        isA<ServiciosAdminLoaded>().having(
          (state) => state.servicios,
          'servicios',
          hasLength(1),
        ),
      ],
    );

    blocTest<ServiciosAdminBloc, ServiciosAdminState>(
      'crea un servicio',
      build: crearBloc,
      seed: estadoCargado,
      act: (bloc) => bloc.add(
        const ServicioCreado(
          nombre: 'Coloración',
          duracionMinutos: 60,
          precio: 12000,
        ),
      ),
      expect: () => [
        isA<ServiciosAdminLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<ServiciosAdminLoaded>()
            .having((state) => state.servicios, 'servicios', hasLength(2))
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
      verify: (_) {
        expect(
          repository.servicios.any((s) => s.nombre == 'Coloración'),
          isTrue,
        );
      },
    );

    blocTest<ServiciosAdminBloc, ServiciosAdminState>(
      'actualiza el precio de un servicio',
      build: crearBloc,
      seed: estadoCargado,
      act: (bloc) => bloc.add(
        const PrecioServicioActualizado(servicioId: '1', precio: 6500),
      ),
      expect: () => [
        isA<ServiciosAdminLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<ServiciosAdminLoaded>()
            .having((state) => state.servicios.first.precio, 'precio', 6500)
            .having((state) => state.successMessage, 'success', isNotNull),
      ],
    );

    blocTest<ServiciosAdminBloc, ServiciosAdminState>(
      'informa error al crear un servicio',
      build: () {
        repository.failOnSave = true;
        return crearBloc();
      },
      seed: estadoCargado,
      act: (bloc) => bloc.add(
        const ServicioCreado(
          nombre: 'Coloración',
          duracionMinutos: 60,
          precio: 12000,
        ),
      ),
      expect: () => [
        isA<ServiciosAdminLoaded>().having(
          (state) => state.guardando,
          'guardando',
          true,
        ),
        isA<ServiciosAdminLoaded>().having(
          (state) => state.errorMessage,
          'error',
          isNotNull,
        ),
      ],
    );

    blocTest<ServiciosAdminBloc, ServiciosAdminState>(
      'limpia los mensajes del catálogo',
      build: crearBloc,
      seed: () => estadoCargado().copyWith(
        successMessage: 'Servicio creado',
        errorMessage: 'Error previo',
      ),
      act: (bloc) => bloc.add(const ServiciosAdminMensajeLimpiado()),
      expect: () => [
        isA<ServiciosAdminLoaded>()
            .having((state) => state.successMessage, 'success', isNull)
            .having((state) => state.errorMessage, 'error', isNull),
      ],
    );
  });
}
