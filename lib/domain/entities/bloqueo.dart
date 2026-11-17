class Bloqueo {
  final String id;
  final String fechaYMD;
  final bool todoElDia;
  final String? horaInicio;
  final String? horaFin;
  final String? motivo;

  const Bloqueo({
    required this.id,
    required this.fechaYMD,
    this.todoElDia = false,
    this.horaInicio,
    this.horaFin,
    this.motivo,
  });

  bool get tieneRango =>
      !todoElDia && horaInicio != null && horaFin != null;

  Bloqueo copyWith({
    String? id,
    String? fechaYMD,
    bool? todoElDia,
    String? horaInicio,
    String? horaFin,
    String? motivo,
  }) {
    return Bloqueo(
      id: id ?? this.id,
      fechaYMD: fechaYMD ?? this.fechaYMD,
      todoElDia: todoElDia ?? this.todoElDia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      motivo: motivo ?? this.motivo,
    );
  }
}
