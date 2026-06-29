import 'cliente.dart';
import 'servicio.dart';

class Turno {
  final String id;
  final Cliente cliente;
  final Servicio servicio;
  final String fechaYMD; // Ejemplo: "2026-06-29"
  final String hora;     // Ejemplo: "14:30"

  Turno({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.fechaYMD,
    required this.hora,
  });
}