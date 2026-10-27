sealed class HistorialClienteEvent {
  const HistorialClienteEvent();
}

final class HistorialClienteBuscado extends HistorialClienteEvent {
  final String telefono;

  const HistorialClienteBuscado(this.telefono);
}
