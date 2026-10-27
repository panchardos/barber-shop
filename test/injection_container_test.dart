import 'package:barber_shop/application/use_cases/actualizar_precio_servicio.dart';
import 'package:barber_shop/application/use_cases/agendar_turno.dart';
import 'package:barber_shop/application/use_cases/cancelar_turno.dart';
import 'package:barber_shop/application/use_cases/configurar_agenda.dart';
import 'package:barber_shop/application/use_cases/crear_servicio.dart';
import 'package:barber_shop/application/use_cases/obtener_catalogo_servicios.dart';
import 'package:barber_shop/application/use_cases/obtener_historial_cliente.dart';
import 'package:barber_shop/application/use_cases/obtener_horarios_disponibles.dart';
import 'package:barber_shop/application/use_cases/obtener_turnos_por_dia.dart';
import 'package:barber_shop/application/use_cases/validar_disponibilidad_horaria.dart';
import 'package:barber_shop/domain/ports/configuracion_repository.dart';
import 'package:barber_shop/domain/ports/servicio_repository.dart';
import 'package:barber_shop/domain/ports/turno_repository.dart';
import 'package:barber_shop/infrastructure/adapters/in_memory_configuracion_adapter.dart';
import 'package:barber_shop/infrastructure/adapters/in_memory_servicio_adapter.dart';
import 'package:barber_shop/infrastructure/adapters/in_memory_turno_adapter.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:barber_shop/injection_container.dart';
import 'package:barber_shop/presentation/blocs/agenda_admin/agenda_admin_bloc.dart';
import 'package:barber_shop/presentation/blocs/configuracion_agenda/configuracion_agenda_bloc.dart';
import 'package:barber_shop/presentation/blocs/historial_cliente/historial_cliente_bloc.dart';
import 'package:barber_shop/presentation/blocs/reserva/reserva_bloc.dart';
import 'package:barber_shop/presentation/blocs/servicios_admin/servicios_admin_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await initDependencies(useRealStorage: false);
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  test('registra adaptadores in-memory y resuelve los casos de uso', () {
    expect(getIt<TurnoRepository>(), isA<InMemoryTurnoAdapter>());
    expect(getIt<ServicioRepository>(), isA<InMemoryServicioAdapter>());
    expect(
      getIt<ConfiguracionRepository>(),
      isA<InMemoryConfiguracionAdapter>(),
    );

    expect(getIt<AgendarTurnoUseCase>(), isA<AgendarTurnoUseCase>());
    expect(
      getIt<ObtenerTurnosPorDiaUseCase>(),
      isA<ObtenerTurnosPorDiaUseCase>(),
    );
    expect(getIt<CancelarTurnoUseCase>(), isA<CancelarTurnoUseCase>());
    expect(
      getIt<ActualizarPrecioServicioUseCase>(),
      isA<ActualizarPrecioServicioUseCase>(),
    );
    expect(
      getIt<ObtenerCatalogoServiciosUseCase>(),
      isA<ObtenerCatalogoServiciosUseCase>(),
    );
    expect(
      getIt<ValidarDisponibilidadHorariaUseCase>(),
      isA<ValidarDisponibilidadHorariaUseCase>(),
    );
    expect(
      getIt<ObtenerHistorialClienteUseCase>(),
      isA<ObtenerHistorialClienteUseCase>(),
    );
    expect(getIt<ConfigurarAgendaUseCase>(), isA<ConfigurarAgendaUseCase>());
    expect(
      getIt<DisponibilidadHorariaService>(),
      isA<DisponibilidadHorariaService>(),
    );
    expect(
      getIt<ObtenerHorariosDisponiblesUseCase>(),
      isA<ObtenerHorariosDisponiblesUseCase>(),
    );
    expect(getIt<CrearServicioUseCase>(), isA<CrearServicioUseCase>());
  });

  test('registra los BLoCs como factories', () async {
    final reserva1 = getIt<ReservaBloc>();
    final reserva2 = getIt<ReservaBloc>();
    expect(reserva1, isA<ReservaBloc>());
    expect(reserva1, isNot(same(reserva2)));

    final agenda1 = getIt<AgendaAdminBloc>();
    final agenda2 = getIt<AgendaAdminBloc>();
    expect(agenda1, isNot(same(agenda2)));

    final servicios1 = getIt<ServiciosAdminBloc>();
    final servicios2 = getIt<ServiciosAdminBloc>();
    expect(servicios1, isNot(same(servicios2)));

    final configuracion1 = getIt<ConfiguracionAgendaBloc>();
    final configuracion2 = getIt<ConfiguracionAgendaBloc>();
    expect(configuracion1, isNot(same(configuracion2)));

    final historial1 = getIt<HistorialClienteBloc>();
    final historial2 = getIt<HistorialClienteBloc>();
    expect(historial1, isNot(same(historial2)));

    await Future.wait([
      reserva1.close(),
      reserva2.close(),
      agenda1.close(),
      agenda2.close(),
      servicios1.close(),
      servicios2.close(),
      configuracion1.close(),
      configuracion2.close(),
      historial1.close(),
      historial2.close(),
    ]);
  });
}
