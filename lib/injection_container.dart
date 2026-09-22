import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Puertos (Dominio)
import 'domain/ports/turno_repository.dart';
import 'domain/ports/servicio_repository.dart';
import 'domain/ports/configuracion_repository.dart';

// Adaptadores (Infraestructura)
import 'infrastructure/adapters/in_memory_turno_adapter.dart';
import 'infrastructure/adapters/in_memory_servicio_adapter.dart';
import 'infrastructure/adapters/in_memory_configuracion_adapter.dart';
import 'infrastructure/adapters/sqflite_turno_adapter.dart';
import 'infrastructure/adapters/shared_preferences_config_adapter.dart';

// Casos de Uso (Aplicación)
import 'application/use_cases/agendar_turno.dart';
import 'application/use_cases/obtener_turnos_por_dia.dart';
import 'application/use_cases/cancelar_turno.dart';
import 'application/use_cases/actualizar_precio_servicio.dart';
import 'application/use_cases/obtener_catalogo_servicios.dart';
import 'application/use_cases/validar_disponibilidad_horaria.dart';
import 'application/use_cases/obtener_historial_cliente.dart';
import 'application/use_cases/configurar_agenda.dart';

final getIt = GetIt.instance;

/// Inicializa el contenedor de dependencias.
/// [useRealStorage]: Permite conmutar de forma transparente entre 
/// almacenamiento real (SQLite + SharedPrefs) y simulado (In-Memory).
Future<void> initDependencies({bool useRealStorage = true}) async {
  await getIt.reset();

  if (useRealStorage) {
    // ----------------------------------------------------------------------
    // 1. MOTORES REALES DE PERSISTENCIA
    // ----------------------------------------------------------------------
    
    // Key-Value: SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Relacional: SQLite
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'barberia.db');
    
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE turnos (
            id TEXT PRIMARY KEY,
            cliente_nombre TEXT NOT NULL,
            cliente_telefono TEXT NOT NULL,
            servicio_id TEXT NOT NULL,
            servicio_nombre TEXT NOT NULL,
            servicio_duracion INTEGER NOT NULL,
            servicio_precio REAL NOT NULL,
            fecha_ymd TEXT NOT NULL,
            hora TEXT NOT NULL
          )
        ''');
      },
    );
    getIt.registerSingleton<Database>(database);

    // ----------------------------------------------------------------------
    // 2. REGISTRO DE ADAPTADORES REALES
    // ----------------------------------------------------------------------
    
    final sqfliteAdapter = SqfliteTurnoAdapter(database);
    await sqfliteAdapter.init();
    getIt.registerSingleton<TurnoRepository>(sqfliteAdapter);

    getIt.registerSingleton<ConfiguracionRepository>(
      SharedPreferencesConfigAdapter(sharedPreferences),
    );

    getIt.registerSingleton<ServicioRepository>(InMemoryServicioAdapter());

  } else {
    // ----------------------------------------------------------------------
    // REGISTRO DE ADAPTADORES SIMULADOS (MOCK / IN-MEMORY)
    // ----------------------------------------------------------------------
    getIt.registerSingleton<TurnoRepository>(InMemoryTurnoAdapter());
    getIt.registerSingleton<ServicioRepository>(InMemoryServicioAdapter());
    getIt.registerSingleton<ConfiguracionRepository>(InMemoryConfiguracionAdapter());
  }

  // ----------------------------------------------------------------------
  // 3. REGISTRO DE CASOS DE USO (8 CASOS DE USO TOTALES)
  // ----------------------------------------------------------------------
  
  getIt.registerLazySingleton<AgendarTurnoUseCase>(
    () => AgendarTurnoUseCase(getIt<TurnoRepository>()),
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

  getIt.registerLazySingleton<ValidarDisponibilidadHorariaUseCase>(
    () => ValidarDisponibilidadHorariaUseCase(getIt<TurnoRepository>()),
  );

  // Nuevos Casos de Uso (HU 7 y HU 8)
  getIt.registerLazySingleton<ObtenerHistorialClienteUseCase>(
    () => ObtenerHistorialClienteUseCase(getIt<TurnoRepository>()),
  );

  getIt.registerLazySingleton<ConfigurarAgendaUseCase>(
    () => ConfigurarAgendaUseCase(getIt<ConfiguracionRepository>()),
  );
}