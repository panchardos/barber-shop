import '../../../domain/entities/bloqueo.dart';

const _sinCambio = Object();

sealed class BloqueosAdminState {
  const BloqueosAdminState();
}

final class BloqueosAdminInitial extends BloqueosAdminState {
  const BloqueosAdminInitial();
}

final class BloqueosAdminLoading extends BloqueosAdminState {
  const BloqueosAdminLoading();
}

final class BloqueosAdminLoaded extends BloqueosAdminState {
  final List<Bloqueo> bloqueos;
  final DateTime fecha;
  final bool guardando;
  final bool eliminando;
  final String? errorMessage;
  final String? successMessage;

  const BloqueosAdminLoaded({
    required this.bloqueos,
    required this.fecha,
    this.guardando = false,
    this.eliminando = false,
    this.errorMessage,
    this.successMessage,
  });

  BloqueosAdminLoaded copyWith({
    List<Bloqueo>? bloqueos,
    DateTime? fecha,
    bool? guardando,
    bool? eliminando,
    Object? errorMessage = _sinCambio,
    Object? successMessage = _sinCambio,
  }) {
    return BloqueosAdminLoaded(
      bloqueos: bloqueos ?? this.bloqueos,
      fecha: fecha ?? this.fecha,
      guardando: guardando ?? this.guardando,
      eliminando: eliminando ?? this.eliminando,
      errorMessage: identical(errorMessage, _sinCambio)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _sinCambio)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

final class BloqueosAdminError extends BloqueosAdminState {
  final String message;

  const BloqueosAdminError(this.message);
}
