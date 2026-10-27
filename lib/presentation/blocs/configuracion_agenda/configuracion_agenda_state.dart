import '../../../domain/entities/configuracion_agenda.dart';

const _sinCambio = Object();

sealed class ConfiguracionAgendaState {
  const ConfiguracionAgendaState();
}

final class ConfiguracionAgendaInitial extends ConfiguracionAgendaState {
  const ConfiguracionAgendaInitial();
}

final class ConfiguracionAgendaLoading extends ConfiguracionAgendaState {
  const ConfiguracionAgendaLoading();
}

final class ConfiguracionAgendaLoaded extends ConfiguracionAgendaState {
  final ConfiguracionAgenda configuracion;
  final bool guardando;
  final String? errorMessage;
  final String? successMessage;

  const ConfiguracionAgendaLoaded({
    required this.configuracion,
    this.guardando = false,
    this.errorMessage,
    this.successMessage,
  });

  ConfiguracionAgendaLoaded copyWith({
    ConfiguracionAgenda? configuracion,
    bool? guardando,
    Object? errorMessage = _sinCambio,
    Object? successMessage = _sinCambio,
  }) {
    return ConfiguracionAgendaLoaded(
      configuracion: configuracion ?? this.configuracion,
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

final class ConfiguracionAgendaError extends ConfiguracionAgendaState {
  final String message;

  const ConfiguracionAgendaError(this.message);
}
