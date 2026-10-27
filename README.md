# La Nota Barber Shop

## Propuesta de Valor
Sistema que optimiza la gestión de turnos para "La Nota Barber Shop", eliminando la incertidumbre en la agenda del barbero y facilitando la reserva autónoma para los clientes, lo que reduce las pérdidas de tiempo en consultas telefónicas y mejora la fidelización.

## Stack Tecnológico
* **Frontend:** Flutter
* **Lenguaje:** Dart / JavaScript
* **Diseño UI/UX:** penpot

## Documentación Técnica
En la carpeta '[/docs](docs)' de este repositorio encontrarás el desglose del modelado técnico que justifica el desarrollo:
- [User Story Map (MVP)](docs/user_story_map.md)
- [Diagramas BPMN](docs/admin_calendario.md)
- [Casos de Uso (UML)](docs/casos_de_uso.md)
- [Wireframes y Flujo de Navegación](docs/wireframe.md)

## Arquitectura

El proyecto sigue una **Arquitectura Hexagonal (Puertos y Adaptadores)**:

```text
lib/
├── domain/
│   ├── entities/    Cliente, Servicio, Turno, ConfiguracionAgenda
│   ├── ports/       Contratos de persistencia
│   ├── services/    Reglas puras de disponibilidad horaria
│   └── exceptions/  Fallos de dominio
├── application/     Casos de uso
├── infrastructure/  Adaptadores, modelos y base de datos
├── presentation/
│   ├── pages/       Vistas de cada flujo
│   ├── widgets/     Componentes reutilizables
│   ├── blocs/       BLoCs, eventos y estados
│   ├── theme/
│   └── utils/
├── injection_container.dart
└── main.dart
```

- El dominio no depende de Flutter, SQLite ni SharedPreferences.
- Los casos de uso reciben interfaces (puertos) por constructor.
- La infraestructura implementa esas interfaces.
- `get_it` actúa como Service Locator.

Documentación ampliada: [Arquitectura y persistencia](docs/arquitectura_tp5.md).

## Gestión de estado

La presentación usa **BLoC**:

- Las páginas solo resuelven su BLoC con `get_it` y lo entregan con `BlocProvider`.
- Las vistas usan `BlocBuilder` con `switch (state)` exhaustivo y `BlocListener` para SnackBars y diálogos.
- Los BLoCs reciben casos de uso por constructor y emiten estados inmutables sellados.
- Los BLoCs se registran con `registerFactory`; los casos de uso y la persistencia siguen como `registerLazySingleton`.

Documentación ampliada: [Gestión de estado](docs/gestion_estado.md).

Para demostrar los estados de carga y error:

```bash
flutter run --dart-define=DEMO_MODE=true
flutter run --dart-define=DEMO_ERROR=true
```

## Persistencia

El sistema usa **persistencia políglota**:

| Tipo | Tecnología | Uso |
|---|---|---|
| Relacional | SQLite (`barberia.db`) | Turnos y catálogo de servicios |
| Clave-valor | SharedPreferences | Configuración de agenda y modo oscuro |
| Volátil | Adaptadores in-memory | Pruebas y modo simulado |

La base SQLite contiene las tablas `turnos` y `servicios`. La versión del esquema es `2` y contempla migración desde la versión anterior.

## Disponibilidad horaria

La configuración de agenda (apertura, cierre y duración de bloque) se usa para calcular los horarios ofrecidos:

1. `DisponibilidadHorariaService` genera los bloques del día.
2. Descarta los horarios pasados y los que no permiten completar el servicio antes del cierre.
3. Excluye bloques superpuestos con turnos existentes, considerando la duración real del servicio.
4. `ObtenerHorariosDisponiblesUseCase` expone el cálculo a la UI.
5. `AgendarTurnoUseCase` vuelve a validar la disponibilidad antes de persistir.

## Historias de Usuario incorporadas en el TP5

- **HU 7:** Configuración de la agenda local.
- **HU 8:** Historial de cliente por teléfono.

Además, la interfaz cubre los flujos de reserva del cliente (HU 2.1, 2.2 y 2.3) y la gestión del catálogo de servicios (HU 6.1 y 6.2).

Ver [HU del TP5](docs/hu_tp5.md).

## Requisitos

- Flutter 3.x o superior.
- Dart 3.x o superior.
- Android Studio / SDK de Android o Xcode para iOS.

## Ejecución

```bash
flutter pub get
flutter run
```

La aplicación inicia con persistencia real:

- SQLite para turnos y servicios.
- SharedPreferences para configuración.

Para usar almacenamiento en memoria durante pruebas:

```dart
await initDependencies(useRealStorage: false);
```

## Análisis y pruebas

```bash
dart analyze lib test
flutter test
```

Las pruebas cubren:

- Mappers bidireccionales de `TurnoModel` y `ServicioModel`.
- Servicio de disponibilidad horaria: bloques, superposición por duración, horarios pasados y configuración inválida.
- Casos de uso de reserva, cancelación, precios, servicios, configuración, historial y disponibilidad.
- Adaptadores SQLite de turnos y servicios.
- Adaptador de configuración con SharedPreferences.
- Creación, siembra y migración de la base de datos.
- Registro de dependencias con `get_it` en modo in-memory.
- BLoCs: estados Initial, Loading, Loaded, Success y Error; eventos y acciones de cada flujo.
- `registerFactory` devolviendo instancias nuevas de cada BLoC.
- Construcción de las páginas y navegación cliente/admin.

Actualmente la suite contiene **102 tests**.

La base SQLite se prueba con `sqflite_common_ffi`, incluido como dependencia de desarrollo.

> En este entorno, `flutter analyze` puede fallar por los caracteres acentuados de la ruta del proyecto. `dart analyze lib test` funciona correctamente.

## Módulos principales

- **Reserva del cliente:** la aplicación abre en este flujo. Permite elegir servicio, fecha, horario disponible y datos personales, y muestra una confirmación.
- **Acceso administrador:** ícono en la cabecera de la reserva.
- **Agenda:** panel con menú lateral, burbujas de fechas, turnos del día, cancelación y alta manual con disponibilidad.
- **Servicios:** alta de servicios y edición de precios.
- **Configuración:** apertura, cierre y duración de bloques.
- **Historial:** búsqueda de turnos por teléfono.

### Navegación

- `/` → reserva del cliente.
- `/admin` → agenda del administrador.
- `/admin/servicios` → catálogo y precios.
- `/admin/configuracion` → parámetros del local.
- `/admin/historial` → historial por teléfono.

## Documentación ampliada del TP5 y TP6

- [HU del TP5](docs/hu_tp5.md)
- [Arquitectura y persistencia](docs/arquitectura_tp5.md)
- [Gestión de estado con BLoC](docs/gestion_estado.md)
- [BPMN del administrador](docs/admin_calendario.md)
- [BPMN de reserva de clientes](docs/reserva_clientes.md)

---
*Desarrollado como proyecto para la materia de Práctica Profesional - 2026*
