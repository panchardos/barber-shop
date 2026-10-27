import '../../../domain/entities/servicio.dart';

const _sinCambio = Object();

sealed class ServiciosAdminState {
  const ServiciosAdminState();
}

final class ServiciosAdminInitial extends ServiciosAdminState {
  const ServiciosAdminInitial();
}

final class ServiciosAdminLoading extends ServiciosAdminState {
  const ServiciosAdminLoading();
}

final class ServiciosAdminLoaded extends ServiciosAdminState {
  final List<Servicio> servicios;
  final bool guardando;
  final String? errorMessage;
  final String? successMessage;

  const ServiciosAdminLoaded({
    required this.servicios,
    this.guardando = false,
    this.errorMessage,
    this.successMessage,
  });

  ServiciosAdminLoaded copyWith({
    List<Servicio>? servicios,
    bool? guardando,
    Object? errorMessage = _sinCambio,
    Object? successMessage = _sinCambio,
  }) {
    return ServiciosAdminLoaded(
      servicios: servicios ?? this.servicios,
      guardando: guardando ?? this.guardando,
      errorMessage: identical(errorMessage, _sinCambio)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _sinCambio)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

final class ServiciosAdminError extends ServiciosAdminState {
  final String message;

  const ServiciosAdminError(this.message);
}
