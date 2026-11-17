class ConfiguracionAgenda {
  static const Set<int> diasLaboralesPorDefecto = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  };

  final String apertura;
  final String cierre;
  final int duracionBloqueMinutos;
  final String? pausaInicio;
  final String? pausaFin;
  final Set<int> diasLaborales;

  const ConfiguracionAgenda({
    required this.apertura,
    required this.cierre,
    required this.duracionBloqueMinutos,
    this.pausaInicio,
    this.pausaFin,
    this.diasLaborales = diasLaboralesPorDefecto,
  });

  bool get tienePausa => pausaInicio != null && pausaFin != null;

  bool esDiaLaboral(int weekday) => diasLaborales.contains(weekday);

  factory ConfiguracionAgenda.defaults() {
    return const ConfiguracionAgenda(
      apertura: '09:00',
      cierre: '20:00',
      duracionBloqueMinutos: 30,
    );
  }

  ConfiguracionAgenda copyWith({
    String? apertura,
    String? cierre,
    int? duracionBloqueMinutos,
    String? pausaInicio,
    String? pausaFin,
    Set<int>? diasLaborales,
    bool limpiarPausa = false,
  }) {
    return ConfiguracionAgenda(
      apertura: apertura ?? this.apertura,
      cierre: cierre ?? this.cierre,
      duracionBloqueMinutos:
          duracionBloqueMinutos ?? this.duracionBloqueMinutos,
      pausaInicio: limpiarPausa ? null : (pausaInicio ?? this.pausaInicio),
      pausaFin: limpiarPausa ? null : (pausaFin ?? this.pausaFin),
      diasLaborales: diasLaborales ?? this.diasLaborales,
    );
  }
}
