import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Puertos (Dominio)
import 'domain/ports/auth_repository.dart';
import 'domain/ports/bloqueo_repository.dart';
import 'domain/ports/configuracion_repository.dart';
import 'domain/ports/servicio_repository.dart';
import 'domain/ports/turno_repository.dart';
import 'domain/services/disponibilidad_horaria_service.dart';

// Adaptadores (Infraestructura)
import 'infrastructure/adapters/allow_all_auth_adapter.dart';
import 'infrastructure/adapters/in_memory_bloqueo_adapter.dart';
import 'infrastructure/adapters/in_memory_configuracion_adapter.dart';
import 'infrastructure/adapters/in_memory_servicio_adapter.dart';
import 'infrastructure/adapters/in_memory_turno_adapter.dart';
import 'infrastructure/adapters/shared_preferences_config_adapter.dart';
import 'infrastructure/adapters/sqflite_bloqueo_adapter.dart';
import 'infrastructure/adapters/sqflite_servicio_adapter.dart';
import 'infrastructure/adapters/sqflite_turno_adapter.dart';
import 'infrastructure/database/barberia_database.dart';
import 'infrastructure/remote/api_auth_adapter.dart';
import 'infrastructure/remote/api_bloqueo_adapter.dart';
import 'infrastructure/remote/api_client.dart';
import 'infrastructure/remote/api_configuracion_adapter.dart';
import 'infrastructure/remote/api_servicio_adapter.dart';
import 'infrastructure/remote/api_turno_adapter.dart';
import 'infrastructure/remote/auth_session.dart';

// Casos de Uso (Aplicación)
import 'application/use_cases/actualizar_precio_servicio.dart';
import 'application/use_cases/agendar_turno.dart';
import 'application/use_cases/cancelar_turno.dart';
import 'application/use_cases/cerrar_sesion_admin.dart';
import 'application/use_cases/configurar_agenda.dart';
import 'application/use_cases/crear_bloqueo.dart';
import 'application/use_cases/crear_servicio.dart';
import 'application/use_cases/eliminar_bloqueo.dart';
import 'application/use_cases/iniciar_sesion_admin.dart';
import 'application/use_cases/obtener_bloqueos_por_dia.dart';
import 'application/use_cases/obtener_catalogo_servicios.dart';
import 'application/use_cases/obtener_configuracion_agenda.dart';
import 'application/use_cases/obtener_historial_cliente.dart';
import 'application/use_cases/obtener_horarios_disponibles.dart';
import 'application/use_cases/obtener_turnos_por_dia.dart';
import 'application/use_cases/verificar_sesion_admin.dart';

// BLoCs (Presentación)
import 'presentation/blocs/agenda_admin/agenda_admin_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/bloqueos_admin/bloqueos_admin_bloc.dart';
import 'presentation/blocs/configuracion_agenda/configuracion_agenda_bloc.dart';
import 'presentation/blocs/historial_cliente/historial_cliente_bloc.dart';
import 'presentation/blocs/reserva/reserva_bloc.dart';
import 'presentation/blocs/servicios_admin/servicios_admin_bloc.dart';

final getIt = GetIt.instance;

enum StorageMode { memory, local, remote }

/// Inicializa el contenedor de dependencias.
///
/// - [StorageMode.memory]: adaptadores en memoria para tests.
/// - [StorageMode.local]: SQLite + SharedPreferences.
/// - [StorageMode.remote]: API HTTP del servidor de demo.
Future<void> initDependencies({StorageMode mode = StorageMode.local}) async {
  await getIt.reset();

  switch (mode) {
    case StorageMode.remote:
      await _registerRemoteAdapters();
    case StorageMode.local:
      await _registerLocalAdapters();
    case StorageMode.memory:
      _registerMemoryAdapters();
  }

  _registerDomainServices();
  _registerUseCases();
  _registerAuthUseCases();
  _registerBlocs();
}

Future<void> _registerLocalAdapters() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  final database = await BarberiaDatabase.open();
  getIt.registerSingleton<Database>(database);

  final turnoAdapter = SqfliteTurnoAdapter(database);
  await turnoAdapter.init();
  getIt.registerSingleton<TurnoRepository>(turnoAdapter);

  final servicioAdapter = SqfliteServicioAdapter(database);
  await servicioAdapter.init();
  getIt.registerSingleton<ServicioRepository>(servicioAdapter);

  getIt.registerSingleton<BloqueoRepository>(SqfliteBloqueoAdapter(database));

  getIt.registerSingleton<ConfiguracionRepository>(
    SharedPreferencesConfigAdapter(sharedPreferences),
  );

  getIt.registerSingleton<AuthRepository>(AllowAllAuthAdapter());
}

void _registerMemoryAdapters() {
  getIt.registerSingleton<TurnoRepository>(InMemoryTurnoAdapter());
  getIt.registerSingleton<ServicioRepository>(InMemoryServicioAdapter());
  getIt.registerSingleton<BloqueoRepository>(InMemoryBloqueoAdapter());
  getIt.registerSingleton<ConfiguracionRepository>(
    InMemoryConfiguracionAdapter(),
  );
  getIt.registerSingleton<AuthRepository>(AllowAllAuthAdapter());
}

Future<void> _registerRemoteAdapters() async {
  final session = AuthSession();
  getIt.registerSingleton<AuthSession>(session);

  final apiClient = ApiClient(baseUrl: _apiBaseUrl(), session: session);
  getIt.registerSingleton<ApiClient>(
    apiClient,
    dispose: (client) => client.close(),
  );

  getIt.registerLazySingleton<ServicioRepository>(
    () => ApiServicioAdapter(apiClient),
  );
  getIt.registerLazySingleton<TurnoRepository>(
    () => ApiTurnoAdapter(apiClient, session),
  );
  getIt.registerLazySingleton<BloqueoRepository>(
    () => ApiBloqueoAdapter(apiClient),
  );
  getIt.registerLazySingleton<ConfiguracionRepository>(
    () => ApiConfiguracionAdapter(apiClient),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => ApiAuthAdapter(apiClient, session),
  );
}

Uri _apiBaseUrl() {
  const configured = String.fromEnvironment('API_BASE_URL');
  if (configured.isNotEmpty) {
    return Uri.parse(configured);
  }
  if (kIsWeb) {
    return Uri.parse(Uri.base.origin);
  }
  return Uri.parse('http://localhost:8080');
}

void _registerDomainServices() {
  getIt.registerLazySingleton<DisponibilidadHorariaService>(
    () => const DisponibilidadHorariaService(),
  );
}

void _registerUseCases() {
  getIt.registerLazySingleton<AgendarTurnoUseCase>(
    () => AgendarTurnoUseCase(
      getIt<TurnoRepository>(),
      getIt<ConfiguracionRepository>(),
      getIt<DisponibilidadHorariaService>(),
      getIt<BloqueoRepository>(),
    ),
  );

  getIt.registerLazySingleton<ObtenerTurnosPorDiaUseCase>(
    () => ObtenerTurnosPorDiaUseCase(getIt<TurnoRepository>()),
  );

  getIt.registerLazySingleton<CancelarTurnoUseCase>(
    () => CancelarTurnoUseCase(getIt<TurnoRepository>()),
  );

  getIt.registerLazySingleton<ActualizarPrecioServicioUseCase>(
    () => ActualizarPrecioServicioUseCase(getIt<ServicioRepository>()),
  );

  getIt.registerLazySingleton<ObtenerCatalogoServiciosUseCase>(
    () => ObtenerCatalogoServiciosUseCase(getIt<ServicioRepository>()),
  );

  getIt.registerLazySingleton<ObtenerHorariosDisponiblesUseCase>(
    () => ObtenerHorariosDisponiblesUseCase(
      getIt<TurnoRepository>(),
      getIt<ConfiguracionRepository>(),
      getIt<DisponibilidadHorariaService>(),
      getIt<BloqueoRepository>(),
    ),
  );

  getIt.registerLazySingleton<ObtenerHistorialClienteUseCase>(
    () => ObtenerHistorialClienteUseCase(getIt<TurnoRepository>()),
  );

  getIt.registerLazySingleton<ObtenerConfiguracionAgendaUseCase>(
    () => ObtenerConfiguracionAgendaUseCase(getIt<ConfiguracionRepository>()),
  );

  getIt.registerLazySingleton<ConfigurarAgendaUseCase>(
    () => ConfigurarAgendaUseCase(getIt<ConfiguracionRepository>()),
  );

  getIt.registerLazySingleton<CrearServicioUseCase>(
    () => CrearServicioUseCase(getIt<ServicioRepository>()),
  );

  getIt.registerLazySingleton<CrearBloqueoUseCase>(
    () => CrearBloqueoUseCase(getIt<BloqueoRepository>()),
  );
  getIt.registerLazySingleton<EliminarBloqueoUseCase>(
    () => EliminarBloqueoUseCase(getIt<BloqueoRepository>()),
  );
  getIt.registerLazySingleton<ObtenerBloqueosPorDiaUseCase>(
    () => ObtenerBloqueosPorDiaUseCase(getIt<BloqueoRepository>()),
  );
}

void _registerAuthUseCases() {
  getIt.registerLazySingleton<IniciarSesionAdminUseCase>(
    () => IniciarSesionAdminUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CerrarSesionAdminUseCase>(
    () => CerrarSesionAdminUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<VerificarSesionAdminUseCase>(
    () => VerificarSesionAdminUseCase(getIt<AuthRepository>()),
  );
}

void _registerBlocs() {
  getIt.registerFactory<ReservaBloc>(
    () => ReservaBloc(
      getIt<ObtenerCatalogoServiciosUseCase>(),
      getIt<ObtenerHorariosDisponiblesUseCase>(),
      getIt<AgendarTurnoUseCase>(),
      getIt<ObtenerConfiguracionAgendaUseCase>(),
    ),
  );

  getIt.registerFactory<AgendaAdminBloc>(
    () => AgendaAdminBloc(
      getIt<ObtenerTurnosPorDiaUseCase>(),
      getIt<CancelarTurnoUseCase>(),
    ),
  );

  getIt.registerFactory<ServiciosAdminBloc>(
    () => ServiciosAdminBloc(
      getIt<ObtenerCatalogoServiciosUseCase>(),
      getIt<CrearServicioUseCase>(),
      getIt<ActualizarPrecioServicioUseCase>(),
    ),
  );

  getIt.registerFactory<ConfiguracionAgendaBloc>(
    () => ConfiguracionAgendaBloc(getIt<ConfigurarAgendaUseCase>()),
  );

  getIt.registerFactory<HistorialClienteBloc>(
    () => HistorialClienteBloc(getIt<ObtenerHistorialClienteUseCase>()),
  );

  getIt.registerFactory<BloqueosAdminBloc>(
    () => BloqueosAdminBloc(
      getIt<ObtenerBloqueosPorDiaUseCase>(),
      getIt<CrearBloqueoUseCase>(),
      getIt<EliminarBloqueoUseCase>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<IniciarSesionAdminUseCase>(),
      getIt<CerrarSesionAdminUseCase>(),
      getIt<VerificarSesionAdminUseCase>(),
    ),
  );
}
