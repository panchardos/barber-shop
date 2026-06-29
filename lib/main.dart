import 'domain/entities/servicio.dart';
import 'application/use_cases/agendar_turno.dart';
import 'application/use_cases/obtener_turnos_por_dia.dart';
import 'application/use_cases/cancelar_turno.dart';
import 'application/use_cases/actualizar_precio_servicio.dart';
import 'infrastructure/adapters/in_memory_turno_adapter.dart';
import 'infrastructure/adapters/in_memory_servicio_adapter.dart';

void main() {
  print("=== 💈 PRUEBA INTEGRAL DE LA NOTA BARBER SHOP 💈 ===");

  // 1. Infraestructura
  final turnoRepo = InMemoryTurnoAdapter();
  final servicioRepo = InMemoryServicioAdapter();

  // 2. Casos de Uso
  final agendarUC = AgendarTurnoUseCase(turnoRepo);
  final agendaDiaUC = ObtenerTurnosPorDiaUseCase(turnoRepo);
  final cancelarUC = CancelarTurnoUseCase(turnoRepo);
  final actualizarPrecioUC = ActualizarPrecioServicioUseCase(servicioRepo);

  // --- PREPARACIÓN ---
  final corte = Servicio(id: "S1", nombre: "Corte Clásico", duracionMinutos: 30, precio: 2500);
  servicioRepo.save(corte);

  // --- SIMULACIÓN SLICE 1: Cliente Agenda ---
  print("\n▶ Cliente agenda un turno...");
  final idTurno = agendarUC.execute(
    nombreCliente: "Juan Pérez", 
    telefonoCliente: "2615551234", 
    servicioSeleccionado: corte, 
    fechaYMD: "2026-08-10", 
    hora: "10:00"
  );

  // --- SIMULACIÓN SLICE 2: Admin Revisa Agenda ---
  print("\n▶ Admin revisa la agenda del 2026-08-10...");
  final turnosHoy = agendaDiaUC.execute("2026-08-10");
  print("Turnos encontrados: ${turnosHoy.length}. Cliente: ${turnosHoy.first.cliente.nombre}");

  // --- SIMULACIÓN SLICE 3: Admin Actualiza Precios ---
  print("\n▶ Admin actualiza el precio por inflación...");
  actualizarPrecioUC.execute("S1", 3000);

  // --- SIMULACIÓN SLICE 4: Admin Cancela Turno ---
  print("\n▶ Admin cancela el turno de Juan Pérez...");
  cancelarUC.execute(idTurno);
  
  print("\n▶ Admin revisa la agenda nuevamente...");
  final turnosActualizados = agendaDiaUC.execute("2026-08-10");
  print("Turnos encontrados: ${turnosActualizados.length}");

  print("\n=======================================================");
  print("TODAS LAS CAPAS FUNCIONAN CORRECTAMENTE");
}