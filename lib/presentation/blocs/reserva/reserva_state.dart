import '../../../domain/entities/servicio.dart';

const _sinCambio = Object();

sealed class ReservaState {
  const ReservaState();
}

final class ReservaInitial extends ReservaState {
  const ReservaInitial();
}

final class ReservaLoading extends ReservaState {
  const ReservaLoading();
}

final class ReservaLoaded extends ReservaState {
  final List<Servicio> servicios;
  final Servicio? servicioSeleccionado;
  final DateTime fecha;
  final List<String> horarios;
  final String? horaSeleccionada;
  final bool cargandoHorarios;
  final bool enviando;
  final String? errorMessage;

  const ReservaLoaded({
    required this.servicios,
    required this.servicioSeleccionado,
    required this.fecha,
    required this.horarios,
    required this.horaSeleccionada,
    this.cargandoHorarios = false,
    this.enviando = false,
    this.errorMessage,
  });

  ReservaLoaded copyWith({
    List<Servicio>? servicios,
    Object? servicioSeleccionado = _sinCambio,
    DateTime? fecha,
    List<String>? horarios,
    Object? horaSeleccionada = _sinCambio,
    bool? cargandoHorarios,
    bool? enviando,
    Object? errorMessage = _sinCambio,
  }) {
    return ReservaLoaded(
      servicios: servicios ?? this.servicios,
      servicioSeleccionado: identical(servicioSeleccionado, _sinCambio)
          ? this.servicioSeleccionado
          : servicioSeleccionado as Servicio?,
      fecha: fecha ?? this.fecha,
      horarios: horarios ?? this.horarios,
      horaSeleccionada: identical(horaSeleccionada, _sinCambio)
          ? this.horaSeleccionada
          : horaSeleccionada as String?,
      cargandoHorarios: cargandoHorarios ?? this.cargandoHorarios,
      enviando: enviando ?? this.enviando,
      errorMessage: identical(errorMessage, _sinCambio)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final class ReservaSuccess extends ReservaState {
  final Servicio servicio;
  final DateTime fecha;
  final String hora;
  final String nombre;

  const ReservaSuccess({
    required this.servicio,
    required this.fecha,
    required this.hora,
    required this.nombre,
  });
}

final class ReservaError extends ReservaState {
  final String message;

  const ReservaError(this.message);
}
