class ConfiguracionAgenda {
  final String apertura;
  final String cierre;
  final int duracionBloqueMinutos;

  const ConfiguracionAgenda({
    required this.apertura,
    required this.cierre,
    required this.duracionBloqueMinutos,
  });

  factory ConfiguracionAgenda.defaults() {
    return const ConfiguracionAgenda(
      apertura: '09:00',
      cierre: '20:00',
      duracionBloqueMinutos: 30,
    );
  }
}
