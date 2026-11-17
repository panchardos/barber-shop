class Servicio {
  final String id;
  final String nombre;
  final int duracionMinutos;
  final double precio;

  const Servicio({
    required this.id,
    required this.nombre,
    required this.duracionMinutos,
    required this.precio,
  });

  Servicio copyWith({
    String? id,
    String? nombre,
    int? duracionMinutos,
    double? precio,
  }) {
    return Servicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      precio: precio ?? this.precio,
    );
  }
}
