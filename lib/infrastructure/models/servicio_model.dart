import '../../domain/entities/servicio.dart';

class ServicioModel {
  final String id;
  final String nombre;
  final int duracionMinutos;
  final double precio;

  const ServicioModel({
    required this.id,
    required this.nombre,
    required this.duracionMinutos,
    required this.precio,
  });

  /// Mapeo desde una fila de SQLite.
  factory ServicioModel.fromSqflite(Map<String, dynamic> map) {
    return ServicioModel(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      duracionMinutos: map['duracion_minutos'] as int,
      precio: (map['precio'] as num).toDouble(),
    );
  }

  /// Mapeo hacia una fila de SQLite.
  Map<String, dynamic> toSqflite() {
    return {
      'id': id,
      'nombre': nombre,
      'duracion_minutos': duracionMinutos,
      'precio': precio,
    };
  }

  /// Alias requerido por la consigna para mappers genéricos.
  factory ServicioModel.fromMap(Map<String, dynamic> map) {
    return ServicioModel.fromSqflite(map);
  }

  /// Alias requerido por la consigna para mappers genéricos.
  Map<String, dynamic> toMap() {
    return toSqflite();
  }

  /// Conversión de Model de Infraestructura a Entidad de Dominio.
  Servicio toEntity() {
    return Servicio(
      id: id,
      nombre: nombre,
      duracionMinutos: duracionMinutos,
      precio: precio,
    );
  }

  /// Conversión de Entidad de Dominio a Model de Infraestructura.
  factory ServicioModel.fromEntity(Servicio servicio) {
    return ServicioModel(
      id: servicio.id,
      nombre: servicio.nombre,
      duracionMinutos: servicio.duracionMinutos,
      precio: servicio.precio,
    );
  }
}
