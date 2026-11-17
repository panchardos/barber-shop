sealed class ConfiguracionAgendaEvent {
  const ConfiguracionAgendaEvent();
}

final class ConfiguracionAgendaCargada extends ConfiguracionAgendaEvent {
  const ConfiguracionAgendaCargada();
}

final class ConfiguracionAgendaGuardada extends ConfiguracionAgendaEvent {
  final String apertura;
  final String cierre;
  final int duracionBloque;
  final String? pausaInicio;
  final String? pausaFin;

  const ConfiguracionAgendaGuardada({
    required this.apertura,
    required this.cierre,
    required this.duracionBloque,
    this.pausaInicio,
    this.pausaFin,
  });
}

final class ConfiguracionAgendaMensajeLimpiado
    extends ConfiguracionAgendaEvent {
  const ConfiguracionAgendaMensajeLimpiado();
}
