import '../../../domain/entities/servicio.dart';

sealed class ReservaEvent {
  const ReservaEvent();
}

final class ReservaIniciada extends ReservaEvent {
  final DateTime fecha;

  const ReservaIniciada(this.fecha);
}

final class ReservaServicioSeleccionado extends ReservaEvent {
  final Servicio servicio;

  const ReservaServicioSeleccionado(this.servicio);
}

final class ReservaFechaSeleccionada extends ReservaEvent {
  final DateTime fecha;

  const ReservaFechaSeleccionada(this.fecha);
}

final class ReservaHorarioSeleccionado extends ReservaEvent {
  final String hora;

  const ReservaHorarioSeleccionado(this.hora);
}

final class ReservaConfirmada extends ReservaEvent {
  final String nombre;
  final String telefono;

  const ReservaConfirmada({required this.nombre, required this.telefono});
}

final class ReservaMensajeLimpiado extends ReservaEvent {
  const ReservaMensajeLimpiado();
}
