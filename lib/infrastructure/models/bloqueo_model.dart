import '../../domain/entities/bloqueo.dart';

class BloqueoModel {
  final String id;
  final String fechaYMD;
  final bool todoElDia;
  final String? horaInicio;
  final String? horaFin;
  final String? motivo;

  const BloqueoModel({
    required this.id,
    required this.fechaYMD,
    required this.todoElDia,
    this.horaInicio,
    this.horaFin,
    this.motivo,
  });

  factory BloqueoModel.fromSqflite(Map<String, dynamic> map) {
    return BloqueoModel(
      id: map['id'] as String,
      fechaYMD: map['fecha_ymd'] as String,
      todoElDia: (map['todo_el_dia'] as int? ?? 0) == 1,
      horaInicio: map['hora_inicio'] as String?,
      horaFin: map['hora_fin'] as String?,
      motivo: map['motivo'] as String?,
    );
  }

  factory BloqueoModel.fromEntity(Bloqueo bloqueo) {
    return BloqueoModel(
      id: bloqueo.id,
      fechaYMD: bloqueo.fechaYMD,
      todoElDia: bloqueo.todoElDia,
      horaInicio: bloqueo.horaInicio,
      horaFin: bloqueo.horaFin,
      motivo: bloqueo.motivo,
    );
  }

  Map<String, dynamic> toSqflite() {
    return {
      'id': id,
      'fecha_ymd': fechaYMD,
      'todo_el_dia': todoElDia ? 1 : 0,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'motivo': motivo,
    };
  }

  Bloqueo toEntity() {
    return Bloqueo(
      id: id,
      fechaYMD: fechaYMD,
      todoElDia: todoElDia,
      horaInicio: horaInicio,
      horaFin: horaFin,
      motivo: motivo,
    );
  }
}
