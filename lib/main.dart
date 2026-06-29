import 'domain/entities/servicio.dart';
import 'application/use_cases/agendar_turno.dart';
import 'application/use_cases/obtener_turnos_por_dia.dart';
import 'application/use_cases/cancelar_turno.dart';
import 'application/use_cases/actualizar_precio_servicio.dart';
import 'application/use_cases/obtener_catalogo_servicios.dart';
import 'application/use_cases/validar_disponibilidad_horaria.dart';
import 'infrastructure/adapters/in_memory_turno_adapter.dart';
import 'infrastructure/adapters/in_memory_servicio_adapter.dart';

void main() {
  print("=======================================================");
  print("💈 DEMOSTRACIÓN DE MVP EN VIVO: LA NOTA BARBER SHOP 💈");
  print("=======================================================");

  // 1. INICIALIZACIÓN DE INFRAESTRUCTURA DE SALIDA (DB SIMULADA)
  final turnoRepo = InMemoryTurnoAdapter();
  final servicioRepo = InMemoryServicioAdapter();

  // 2. INYECCIÓN DE DEPENDENCIAS A LOS CASOS DE USO (NÚCLEO)
  final agendarUC = AgendarTurnoUseCase(turnoRepo);
  final agendaDiaUC = ObtenerTurnosPorDiaUseCase(turnoRepo);
  final cancelarUC = CancelarTurnoUseCase(turnoRepo);
  final actualizarPrecioUC = ActualizarPrecioServicioUseCase(servicioRepo);
  final obtenerCatalogoUC = ObtenerCatalogoServiciosUseCase(servicioRepo);
  final validarHorarioUC = ValidarDisponibilidadHorariaUseCase(turnoRepo);

  // --- POBLAR CATÁLOGO INICIAL (Simulación de Datos Base) ---
  final corteClasico = Servicio(id: "S1", nombre: "Corte Clásico", duracionMinutos: 30, precio: 2500);
  final barbaPro = Servicio(id: "S2", nombre: "Perfilado de Barba", duracionMinutos: 20, precio: 1500);
  servicioRepo.save(corteClasico);
  servicioRepo.save(barbaPro);

  // ----------------------------------------------------------------------
  // CASO DE USO 1: Obtener Catálogo de Servicios
  // ----------------------------------------------------------------------
  print("\n▶ [Caso de Uso 1] Ejecutando: ObtenerCatalogoServiciosUseCase...");
  final catalogo = obtenerCatalogoUC.execute();
  print("   Catálogo recuperado con éxito. Servicios disponibles:");
  for (var s in catalogo) {
    print("   - [${s.id}] ${s.nombre} | Precio: \$${s.precio}");
  }

  // ----------------------------------------------------------------------
  // CASO DE USO 2: Validar Disponibilidad Horaria (Antes de agendar)
  // ----------------------------------------------------------------------
  const fechaTest = "2026-07-20";
  const horaTest = "16:00";
  
  print("\n▶ [Caso de Uso 2] Ejecutando: ValidarDisponibilidadHorariaUseCase...");
  final estaLibre1 = validarHorarioUC.execute(fechaTest, horaTest);
  print("   ¿Horario ($fechaTest a las $horaTest) disponible?: $estaLibre1");

  // ----------------------------------------------------------------------
  // CASO DE USO 3: Agendar Turno (Escritura / Persistencia)
  // ----------------------------------------------------------------------
  print("\n▶ [Caso de Uso 3] Ejecutando: AgendarTurnoUseCase...");
  final idTurno = agendarUC.execute(
    nombreCliente: "Matias Corts", 
    telefonoCliente: "2614445555", 
    servicioSeleccionado: corteClasico, 
    fechaYMD: fechaTest, 
    hora: horaTest
  );
  print("   ✅ Éxito. Turno confirmado en el sistema.");

  // Re-validamos el mismo horario para demostrar el control en vivo
  print("   Volviendo a consultar disponibilidad del mismo horario...");
  final estaLibre2 = validarHorarioUC.execute(fechaTest, horaTest);
  print("   ¿Horario disponible ahora?: $estaLibre2 (Bloqueado correctamente)");

  // ----------------------------------------------------------------------
  // CASO DE USO 4: Obtener Turnos por Día (Admin Agenda)
  // ----------------------------------------------------------------------
  print("\n▶ [Caso de Uso 4] Ejecutando: ObtenerTurnosPorDiaUseCase...");
  final agendaDeHoy = agendaDiaUC.execute(fechaTest);
  print("   Panel del Administrador cargado para el día $fechaTest:");
  print("   Cantidad de turnos agendados: ${agendaDeHoy.length}");
  print("   - Turno ID: ${agendaDeHoy.first.id} | Cliente: ${agendaDeHoy.first.cliente.nombre} | Hora: ${agendaDeHoy.first.hora}");

  // ----------------------------------------------------------------------
  // CASO DE USO 5: Actualizar Precio de Servicio (Admin Configuración)
  // ----------------------------------------------------------------------
  print("\n▶ [Caso de Uso 5] Ejecutando: ActualizarPrecioServicioUseCase...");
  actualizarPrecioUC.execute("S1", 3200.0);
  print("   Verificando nuevo precio en el catálogo...");
  print("   - Nuevo precio de Corte Clásico: \$${servicioRepo.findById("S1")?.precio}");

  // ----------------------------------------------------------------------
  // CASO DE USO 6: Cancelar Turno (Admin Gestión / Baja)
  // ----------------------------------------------------------------------
  print("\n▶ [Caso de Uso 6] Ejecutando: CancelarTurnoUseCase...");
  cancelarUC.execute(idTurno);

  print("   Consultando panel del administrador post-cancelación...");
  final agendaPostCancelacion = agendaDiaUC.execute(fechaTest);
  print("   Cantidad de turnos en agenda: ${agendaPostCancelacion.length}");

  print("\n=======================================");
  print("LOS 6 CASOS DE USO CORRIERON SIN ERRORES");

}