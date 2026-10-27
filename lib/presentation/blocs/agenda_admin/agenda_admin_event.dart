import '../../../domain/entities/turno.dart';

sealed class AgendaAdminEvent {
  const AgendaAdminEvent();
}

final class AgendaAdminCargada extends AgendaAdminEvent {
  final DateTime? fecha;

  const AgendaAdminCargada({this.fecha});
}

final class AgendaAdminFechaSeleccionada extends AgendaAdminEvent {
  final DateTime fecha;

  const AgendaAdminFechaSeleccionada(this.fecha);
}

final class AgendaAdminTurnoCancelado extends AgendaAdminEvent {
  final Turno turno;

  const AgendaAdminTurnoCancelado(this.turno);
}

final class AgendaAdminRefrescada extends AgendaAdminEvent {
  const AgendaAdminRefrescada();
}

final class AgendaAdminMensajeLimpiado extends AgendaAdminEvent {
  const AgendaAdminMensajeLimpiado();
}
