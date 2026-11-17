class ConfiguracionAgenda {
  final String apertura;
  final String cierre;
  final int duracionBloqueMinutos;
  final String? pausaInicio;
  final String? pausaFin;

  const ConfiguracionAgenda({
    required this.apertura,
    required this.cierre,
    required this.duracionBloqueMinutos,
    this.pausaInicio,
    this.pausaFin,
  });

  bool get tienePausa => pausaInicio != null && pausaFin != null;

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
    bool limpiarPausa = false,
  }) {
    return ConfiguracionAgenda(
      apertura: apertura ?? this.apertura,
      cierre: cierre ?? this.cierre,
      duracionBloqueMinutos:
          duracionBloqueMinutos ?? this.duracionBloqueMinutos,
      pausaInicio: limpiarPausa ? null : (pausaInicio ?? this.pausaInicio),
      pausaFin: limpiarPausa ? null : (pausaFin ?? this.pausaFin),
    );
  }
}
