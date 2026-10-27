# Gestión de Estado — TP6

## Decisión: BLoC

Se eligió **BLoC** porque el flujo de la aplicación se entiende como una secuencia explícita de intenciones del usuario (eventos) que producen estados inmutables:

```text
UI → Evento → BLoC → Caso de uso → Repositorio
                  ↓
              Nuevo estado → UI
```

Ventajas para este proyecto:

- Los eventos documentan las acciones posibles de cada flujo.
- Los estados sellados permiten un `switch` exhaustivo en la UI.
- El desacoplamiento es total: las páginas no conocen casos de uso ni repositorios.
- `BlocListener` centraliza efectos secundarios como SnackBars y confirmaciones.
- `registerFactory` garantiza una instancia nueva por pantalla.

## Estructura de presentación

```text
lib/presentation/
├── pages/
│   ├── agenda_admin_page.dart
│   ├── configuracion_agenda_page.dart
│   ├── historial_cliente_page.dart
│   ├── reserva_cliente_page.dart
│   └── servicios_admin_page.dart
├── widgets/
│   ├── admin_scaffold.dart
│   ├── cancelar_turno_dialog.dart
│   ├── date_bubble.dart
│   ├── nuevo_turno_sheet.dart
│   ├── section_title.dart
│   ├── service_select_card.dart
│   ├── time_slot_grid.dart
│   └── turno_card.dart
├── blocs/
│   ├── agenda_admin/
│   │   ├── agenda_admin_bloc.dart
│   │   ├── agenda_admin_event.dart
│   │   └── agenda_admin_state.dart
│   ├── configuracion_agenda/
│   ├── historial_cliente/
│   ├── reserva/
│   └── servicios_admin/
├── theme/
├── utils/
└── app_routes.dart
```

## Flujos y BLoCs

| BLoC | Eventos principales | Estados |
|---|---|---|
| `ReservaBloc` | `ReservaIniciada`, `ReservaServicioSeleccionado`, `ReservaFechaSeleccionada`, `ReservaHorarioSeleccionado`, `ReservaConfirmada`, `ReservaMensajeLimpiado` | `ReservaInitial`, `ReservaLoading`, `ReservaLoaded`, `ReservaSuccess`, `ReservaError` |
| `AgendaAdminBloc` | `AgendaAdminCargada`, `AgendaAdminFechaSeleccionada`, `AgendaAdminTurnoCancelado`, `AgendaAdminRefrescada`, `AgendaAdminMensajeLimpiado` | `AgendaAdminInitial`, `AgendaAdminLoading`, `AgendaAdminLoaded`, `AgendaAdminError` |
| `ServiciosAdminBloc` | `ServiciosAdminCargados`, `ServicioCreado`, `PrecioServicioActualizado`, `ServiciosAdminMensajeLimpiado` | `ServiciosAdminInitial`, `ServiciosAdminLoading`, `ServiciosAdminLoaded`, `ServiciosAdminError` |
| `ConfiguracionAgendaBloc` | `ConfiguracionAgendaCargada`, `ConfiguracionAgendaGuardada`, `ConfiguracionAgendaMensajeLimpiado` | `ConfiguracionAgendaInitial`, `ConfiguracionAgendaLoading`, `ConfiguracionAgendaLoaded`, `ConfiguracionAgendaError` |
| `HistorialClienteBloc` | `HistorialClienteBuscado` | `HistorialClienteInitial`, `HistorialClienteLoading`, `HistorialClienteLoaded`, `HistorialClienteError` |

`ReservaBloc` se reutiliza en la reserva pública y en el alta manual del administrador.

## Ejemplo de estado sellado

Archivo: `lib/presentation/blocs/reserva/reserva_state.dart`

```dart
sealed class ReservaState {
  const ReservaState();
}

final class ReservaInitial extends ReservaState {
  const ReservaInitial();
}

final class ReservaLoading extends ReservaState {
  const ReservaLoading();
}

final class ReservaLoaded extends ReservaState {
  final List<Servicio> servicios;
  final Servicio? servicioSeleccionado;
  final DateTime fecha;
  final List<String> horarios;
  final String? horaSeleccionada;
  final bool cargandoHorarios;
  final bool enviando;
  final String? errorMessage;

  const ReservaLoaded({
    required this.servicios,
    required this.servicioSeleccionado,
    required this.fecha,
    required this.horarios,
    required this.horaSeleccionada,
    this.cargandoHorarios = false,
    this.enviando = false,
    this.errorMessage,
  });
}

final class ReservaSuccess extends ReservaState {
  final Servicio servicio;
  final DateTime fecha;
  final String hora;
  final String nombre;

  const ReservaSuccess({
    required this.servicio,
    required this.fecha,
    required this.hora,
    required this.nombre,
  });
}

final class ReservaError extends ReservaState {
  final String message;

  const ReservaError(this.message);
}
```

## Ejemplo de BLoC

Archivo: `lib/presentation/blocs/reserva/reserva_bloc.dart`

```dart
class ReservaBloc extends Bloc<ReservaEvent, ReservaState> {
  final ObtenerCatalogoServiciosUseCase _obtenerCatalogo;
  final ObtenerHorariosDisponiblesUseCase _obtenerHorarios;
  final AgendarTurnoUseCase _agendarTurno;

  ReservaBloc(
    this._obtenerCatalogo,
    this._obtenerHorarios,
    this._agendarTurno,
  ) : super(const ReservaInitial()) {
    on<ReservaIniciada>(_onIniciada);
    on<ReservaServicioSeleccionado>(_onServicioSeleccionado);
    on<ReservaFechaSeleccionada>(_onFechaSeleccionada);
    on<ReservaHorarioSeleccionado>(_onHorarioSeleccionado);
    on<ReservaConfirmada>(_onConfirmada);
    on<ReservaMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onIniciada(
    ReservaIniciada event,
    Emitter<ReservaState> emit,
  ) async {
    emit(const ReservaLoading());
    // ... llama a los casos de uso y emite ReservaLoaded o ReservaError
  }
}
```

## Registro en get_it

Archivo: `lib/injection_container.dart`

```dart
// Datos y dominio: una instancia reutilizable.
sl.registerLazySingleton<ObtenerCatalogoServiciosUseCase>(
  () => ObtenerCatalogoServiciosUseCase(getIt<ServicioRepository>()),
);

// Presentación: una instancia nueva por pantalla.
sl.registerFactory<ReservaBloc>(
  () => ReservaBloc(
    getIt<ObtenerCatalogoServiciosUseCase>(),
    getIt<ObtenerHorariosDisponiblesUseCase>(),
    getIt<AgendarTurnoUseCase>(),
  ),
);
```

## Página con BLoC

Archivo: `lib/presentation/pages/reserva_cliente_page.dart`

```dart
class ReservaClientePage extends StatelessWidget {
  const ReservaClientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReservaBloc>()
        ..add(ReservaIniciada(soloFecha(DateTime.now()))),
      child: const _ReservaClienteView(),
    );
  }
}
```

La vista usa `BlocBuilder` con `switch` exhaustivo y `BlocListener` para errores y confirmaciones:

```dart
BlocBuilder<ReservaBloc, ReservaState>(
  builder: (context, state) {
    return switch (state) {
      ReservaInitial() || ReservaLoading() => const CircularProgressIndicator(),
      ReservaError(:final message) => ErrorView(message),
      ReservaSuccess() => const SizedBox.shrink(),
      ReservaLoaded() => Formulario(state),
    };
  },
)
```

## Formularios de texto

Los `TextEditingController` se mantienen únicamente para los campos de entrada (nombre, teléfono, precio, etc.). El estado de negocio —listas, horarios, loading, errores, selección— vive en el BLoC.

Motivos:

- El controlador maneja cursor, foco y teclado.
- No se emite un evento por cada tecla, evitando reconstrucciones y saltos de cursor.
- El BLoC sigue siendo la única fuente de verdad para los datos del flujo.

## Pruebas

Se agregó `bloc_test` y se cubren:

- Emisión de `Loading`, `Loaded`, `Success` y `Error`.
- Selección de servicio, fecha y horario.
- Confirmación de reserva y error por superposición.
- Carga, cancelación y refresco de la agenda.
- Creación de servicios y actualización de precios.
- Carga y guardado de configuración.
- Búsqueda de historial.
- `registerFactory` devolviendo instancias distintas.

Comandos:

```bash
dart analyze lib test
flutter test
```

## Modo demostración

Como las operaciones locales son instantáneas, los estados `Loading` pueden durar pocos milisegundos. Para la defensa oral se agregó un modo demo:

```bash
# Carga con una pausa de 900 ms para ver los estados Loading.
flutter run --dart-define=DEMO_MODE=true

# Fuerza un error en la primera carga de la reserva.
# Al reintentar, la carga continúa normalmente.
flutter run --dart-define=DEMO_ERROR=true
```

`DEMO_ERROR` aplica al primer intento de carga de `ReservaBloc`. El botón `REINTENTAR` vuelve a ejecutar `ReservaIniciada` y permite continuar con la demostración.

## Defensa oral

Puntos para explicar:

1. La UI solo conoce eventos y estados; no importa casos de uso ni repositorios.
2. El BLoC orquesta casos de uso y traduce sus resultados a estados inmutables.
3. `registerFactory` respeta el ciclo de vida de cada pantalla.
4. `BlocProvider` crea y cierra el BLoC automáticamente.
5. `BlocListener` concentra SnackBars y diálogos.
6. Las reglas de negocio y la persistencia siguen fuera de la presentación.

## Git

- Rama: `feature/gestion-estado-cubit-bloc`
- Commits semánticos: `feat:`, `refactor:`, `test:`, `docs:`
- Merge a `main`
- Tag: `v1.0-mvp`
