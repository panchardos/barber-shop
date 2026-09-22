import '../../domain/entities/turno.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/servicio.dart';

class TurnoModel {
  final String id;
  final String clienteNombre;
  final String clienteTelefono;
  final String servicioId;
  final String servicioNombre;
  final int servicioDuracion;
  final double servicioPrecio;
  final String fechaYMD;
  final String hora;

  TurnoModel({
    required this.id,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.servicioId,
    required this.servicioNombre,
    required this.servicioDuracion,
    required this.servicioPrecio,
    required this.fechaYMD,
    required this.hora,
  });

  /// Mapeo desde un Map devuelto por SQFlite (Fila de la BD)
  factory TurnoModel.fromSqflite(Map<String, dynamic> map) {
    return TurnoModel(
      id: map['id'] as String,
      clienteNombre: map['cliente_nombre'] as String,
      clienteTelefono: map['cliente_telefono'] as String,
      servicioId: map['servicio_id'] as String,
      servicioNombre: map['servicio_nombre'] as String,
      servicioDuracion: map['servicio_duracion'] as int,
      servicioPrecio: (map['servicio_precio'] as num).toDouble(),
      fechaYMD: map['fecha_ymd'] as String,
      hora: map['hora'] as String,
    );
  }

  /// Mapeo hacia un Map plano para insertar en SQFlite
  Map<String, dynamic> toSqflite() {
    return {
      'id': id,
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'servicio_id': servicioId,
      'servicio_nombre': servicioNombre,
      'servicio_duracion': servicioDuracion,
      'servicio_precio': servicioPrecio,
      'fecha_ymd': fechaYMD,
      'hora': hora,
    };
  }

  /// Conversión de Model de Infraestructura a Entidad de Dominio
  Turno toEntity() {
    return Turno(
      id: id,
      cliente: Cliente(nombre: clienteNombre, telefono: clienteTelefono),
      servicio: Servicio(
        id: servicioId,
        nombre: servicioNombre,
        duracionMinutos: servicioDuracion,
        precio: servicioPrecio,
      ),
      fechaYMD: fechaYMD,
      hora: hora,
    );
  }

  /// Conversión de Entidad de Dominio a Model de Infraestructura
  factory TurnoModel.fromEntity(Turno turno) {
    return TurnoModel(
      id: turno.id,
      clienteNombre: turno.cliente.nombre,
      clienteTelefono: turno.cliente.telefono,
      servicioId: turno.servicio.id,
      servicioNombre: turno.servicio.nombre,
      servicioDuracion: turno.servicio.duracionMinutos,
      servicioPrecio: turno.servicio.precio,
      fechaYMD: turno.fechaYMD,
      hora: turno.hora,
    );
  }
}