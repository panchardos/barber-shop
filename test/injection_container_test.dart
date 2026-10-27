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
}
