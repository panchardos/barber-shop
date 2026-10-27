import '../../../domain/entities/turno.dart';

sealed class HistorialClienteState {
  const HistorialClienteState();
}

final class HistorialClienteInitial extends HistorialClienteState {
  const HistorialClienteInitial();
}

final class HistorialClienteLoading extends HistorialClienteState {
  const HistorialClienteLoading();
}

final class HistorialClienteLoaded extends HistorialClienteState {
  final List<Turno> turnos;

  const HistorialClienteLoaded(this.turnos);
}

final class HistorialClienteError extends HistorialClienteState {
  final String message;

  const HistorialClienteError(this.message);
}
