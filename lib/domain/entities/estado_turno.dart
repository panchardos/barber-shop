enum EstadoTurno {
  reservado,
  cancelado;

  static EstadoTurno fromValue(String? value) {
    return value == 'cancelado' ? EstadoTurno.cancelado : EstadoTurno.reservado;
  }

  String get value => name;
}
