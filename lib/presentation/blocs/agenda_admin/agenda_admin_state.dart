import '../../../domain/entities/turno.dart';

const _sinCambio = Object();

sealed class AgendaAdminState {
  const AgendaAdminState();
}

final class AgendaAdminInitial extends AgendaAdminState {
  const AgendaAdminInitial();
}

final class AgendaAdminLoading extends AgendaAdminState {
  const AgendaAdminLoading();
}

final class AgendaAdminLoaded extends AgendaAdminState {
  final List<Turno> turnos;
  final DateTime fecha;
  final bool cargando;
  final bool cancelando;
  final String? errorMessage;
  final String? successMessage;

  const AgendaAdminLoaded({
    required this.turnos,
    required this.fecha,
    this.cargando = false,
    this.cancelando = false,
    this.errorMessage,
    this.successMessage,
  });

  AgendaAdminLoaded copyWith({
    List<Turno>? turnos,
    DateTime? fecha,
    bool? cargando,
    bool? cancelando,
    Object? errorMessage = _sinCambio,
    Object? successMessage = _sinCambio,
  }) {
    return AgendaAdminLoaded(
      turnos: turnos ?? this.turnos,
      fecha: fecha ?? this.fecha,
      cargando: cargando ?? this.cargando,
      cancelando: cancelando ?? this.cancelando,
      errorMessage: identical(errorMessage, _sinCambio)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _sinCambio)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

final class AgendaAdminError extends AgendaAdminState {
  final String message;

  const AgendaAdminError(this.message);
}
