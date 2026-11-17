import 'cliente.dart';
import 'estado_turno.dart';
import 'servicio.dart';

class Turno {
  final String id;
  final Cliente cliente;
  final Servicio servicio;
  final String fechaYMD; // Ejemplo: "2026-06-29"
  final String hora; // Ejemplo: "14:30"
  final EstadoTurno estado;

  Turno({
    required this.id,
    required this.cliente,
    required this.servicio,
    required this.fechaYMD,
    required this.hora,
    this.estado = EstadoTurno.reservado,
  });

  bool get estaCancelado => estado == EstadoTurno.cancelado;

  Turno copyWith({
    String? id,
    Cliente? cliente,
    Servicio? servicio,
    String? fechaYMD,
    String? hora,
    EstadoTurno? estado,
  }) {
    return Turno(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      servicio: servicio ?? this.servicio,
      fechaYMD: fechaYMD ?? this.fechaYMD,
      hora: hora ?? this.hora,
      estado: estado ?? this.estado,
    );
  }
}
