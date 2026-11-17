sealed class BloqueosAdminEvent {
  const BloqueosAdminEvent();
}

final class BloqueosAdminCargados extends BloqueosAdminEvent {
  final DateTime fecha;

  const BloqueosAdminCargados(this.fecha);
}

final class BloqueoAgregado extends BloqueosAdminEvent {
  final DateTime fecha;
  final bool todoElDia;
  final String? horaInicio;
  final String? horaFin;
  final String? motivo;

  const BloqueoAgregado({
    required this.fecha,
    required this.todoElDia,
    this.horaInicio,
    this.horaFin,
    this.motivo,
  });
}

final class BloqueoEliminado extends BloqueosAdminEvent {
  final String id;

  const BloqueoEliminado(this.id);
}

final class BloqueosAdminMensajeLimpiado extends BloqueosAdminEvent {
  const BloqueosAdminMensajeLimpiado();
}
