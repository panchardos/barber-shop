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
├── domain/          Entidades, puertos y excepciones puras
├── application/     Casos de uso
├── infrastructure/  Adaptadores, modelos y base de datos
├── presentation/    Pantallas Flutter
├── injection_container.dart
└── main.dart
```

- El dominio no depende de Flutter, SQLite ni SharedPreferences.
- Los casos de uso reciben interfaces (puertos) por constructor.
- La infraestructura implementa esas interfaces.
- `get_it` actúa como Service Locator.

Documentación ampliada: [Arquitectura y persistencia](docs/arquitectura_tp5.md).

## Persistencia

El sistema usa **persistencia políglota**:

| Tipo | Tecnología | Uso |
|---|---|---|
| Relacional | SQLite (`barberia.db`) | Turnos y catálogo de servicios |
| Clave-valor | SharedPreferences | Configuración de agenda y modo oscuro |
| Volátil | Adaptadores in-memory | Pruebas y modo simulado |

La base SQLite contiene las tablas `turnos` y `servicios`. La versión del esquema es `2` y contempla migración desde la versión anterior.

## Historias de Usuario incorporadas en el TP5

- **HU 7:** Configuración de la agenda local.
- **HU 8:** Historial de cliente por teléfono.

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
- Casos de uso de reserva, cancelación, precios, configuración, historial y disponibilidad.
- Adaptadores SQLite de turnos y servicios.
- Adaptador de configuración con SharedPreferences.
- Creación, siembra y migración de la base de datos.
- Registro de dependencias con `get_it` en modo in-memory.

La base SQLite se prueba con `sqflite_common_ffi`, incluido como dependencia de desarrollo.

> En este entorno, `flutter analyze` puede fallar por los caracteres acentuados de la ruta del proyecto. `dart analyze lib test` funciona correctamente.

## Módulos principales

- **Agenda:** listado de turnos por fecha, alta y cancelación.
- **Configuración:** apertura, cierre y duración de bloques.
- **Historial:** búsqueda de turnos por teléfono.
- **Catálogo:** servicios con duración y precio persistidos en SQLite.

## Documentación ampliada del TP5

- [HU del TP5](docs/hu_tp5.md)
- [Arquitectura y persistencia](docs/arquitectura_tp5.md)
- [BPMN del administrador](docs/admin_calendario.md)
- [BPMN de reserva de clientes](docs/reserva_clientes.md)

---
*Desarrollado como proyecto para la materia de Práctica Profesional - 2026*
