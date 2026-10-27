# Historias de Usuario del TP5

## Contexto

El MVP original de **La Nota Barber Shop** quedó definido en el TP1 con las épicas E1 a E6. El TP5 mantiene los cinco casos de uso previos y agrega dos Historias de Usuario nuevas, con sus correspondientes casos de uso, pantallas y persistencia real.

Las nuevas historias son:

- **HU 7:** Configuración de la agenda local.
- **HU 8:** Historial de cliente por teléfono.

---

## HU 7 — Configuración de la agenda local

**Como** peluquero administrador,
**quiero** configurar la hora de apertura, la hora de cierre y la duración de los bloques de atención,
**para** conservar mis parámetros de trabajo y evitar perderlos al cerrar la aplicación.

### Criterios de aceptación

1. **Carga de valores actuales**
   - Dado que el administrador ingresa a `Configuración de Agenda`,
   - cuando la pantalla termina de cargar,
   - entonces debe mostrar los valores guardados previamente.
   - Si no existe configuración guardada, debe mostrar los valores por defecto: apertura `09:00`, cierre `20:00` y duración `30` minutos.

2. **Validación de formato**
   - Dado que el administrador completa el formulario,
   - cuando ingresa una hora con formato distinto de `HH:MM` o una duración que no sea un número entero mayor a cero,
   - entonces el sistema debe mostrar el error de validación y no guardar los cambios.

3. **Coherencia horaria**
   - Dado que el administrador ingresa la apertura y el cierre,
   - cuando la hora de apertura es igual o posterior a la hora de cierre,
   - entonces el sistema debe mostrar un mensaje de error y no guardar los cambios.

4. **Persistencia**
   - Dado que el administrador completa datos válidos,
   - cuando presiona `Guardar Cambios`,
   - entonces el sistema debe guardar la configuración en `SharedPreferences` y mostrar una confirmación.
   - Al reiniciar la aplicación, los valores deben recuperarse correctamente.

5. **Manejo de errores**
   - Dado que ocurre un error técnico al guardar,
   - cuando el adaptador de persistencia falla,
   - entonces la pantalla debe mostrar un mensaje de error y permanecer abierta para reintentar.

### Trazabilidad

| Elemento | Implementación |
|---|---|
| Caso de uso | `ConfigurarAgendaUseCase` |
| Pantalla | `ConfiguracionAgendaScreen` |
| Entidad | `ConfiguracionAgenda` |
| Puerto | `ConfiguracionRepository` |
| Adaptador real | `SharedPreferencesConfigAdapter` |
| Adaptador mock | `InMemoryConfiguracionAdapter` |

---

## HU 8 — Historial de cliente por teléfono

**Como** peluquero administrador,
**quiero** buscar los turnos de un cliente por su número de teléfono,
**para** consultar su historial de atenciones y conocer su frecuencia de visita.

### Criterios de aceptación

1. **Teléfono obligatorio**
   - Dado que el administrador está en la pantalla de historial,
   - cuando intenta buscar con el campo de teléfono vacío,
   - entonces el sistema no debe ejecutar la búsqueda.

2. **Búsqueda por teléfono**
   - Dado que el administrador ingresa un número de teléfono,
   - cuando presiona el botón de búsqueda,
   - entonces el sistema debe recuperar todos los turnos asociados exactamente a ese número.

3. **Orden cronológico**
   - Dado que existen varios turnos para el mismo cliente,
   - cuando se muestran los resultados,
   - entonces deben aparecer ordenados por fecha descendente.
   - Si dos turnos comparten la misma fecha, deben ordenarse por hora descendente.

4. **Información visible**
   - Dado que se encontraron turnos,
   - cuando se renderiza cada tarjeta,
   - entonces debe mostrarse el servicio, el precio, la fecha, la hora y el nombre del cliente.

5. **Estado vacío**
   - Dado que no existen turnos para el teléfono consultado,
   - cuando finaliza la búsqueda,
   - entonces el sistema debe mostrar un mensaje indicando que no se encontraron registros.

6. **Persistencia**
   - Dado que la aplicación se reinicia,
   - cuando el administrador vuelve a buscar el mismo teléfono,
   - entonces los turnos deben seguir disponibles porque se almacenan en SQLite.

### Trazabilidad

| Elemento | Implementación |
|---|---|
| Caso de uso | `ObtenerHistorialClienteUseCase` |
| Pantalla | `HistorialClienteScreen` |
| Puerto | `TurnoRepository` |
| Adaptador real | `SqfliteTurnoAdapter` |
| Adaptador mock | `InMemoryTurnoAdapter` |

---

## Casos de uso previos mantenidos

El TP5 conserva los cinco casos de uso del MVP anterior:

1. `AgendarTurnoUseCase`
2. `ObtenerTurnosPorDiaUseCase`
3. `CancelarTurnoUseCase`
4. `ActualizarPrecioServicioUseCase`
5. `ObtenerCatalogoServiciosUseCase`

Además, se mantiene `ValidarDisponibilidadHorariaUseCase` como apoyo al flujo de reserva.
