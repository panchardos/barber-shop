class ServerAvailability {
  const ServerAvailability._();

  static List<String> availableSlots({
    required String fechaYMD,
    required Map<String, dynamic> config,
    required Map<String, dynamic> service,
    required List<Map<String, dynamic>> occupied,
    DateTime? now,
  }) {
    final apertura = _parseHora(config['apertura'] as String?);
    final cierre = _parseHora(config['cierre'] as String?);
    final bloque = _asInt(config['duracion_bloque_minutos']);
    final duracionServicio = _asInt(service['duracion_minutos']);

    if (apertura == null || cierre == null) {
      throw const FormatException('La configuración horaria es inválida.');
    }
    if (apertura >= cierre) {
      throw const FormatException(
        'La hora de apertura debe ser anterior al cierre.',
      );
    }
    if (bloque == null || bloque <= 0) {
      throw const FormatException(
        'La duración de bloque debe ser mayor a cero.',
      );
    }
    if (duracionServicio == null || duracionServicio <= 0) {
      throw const FormatException(
        'La duración del servicio debe ser mayor a cero.',
      );
    }

    final momento = now ?? DateTime.now();
    final fechaActual = _fechaYMD(momento);
    if (fechaYMD.compareTo(fechaActual) < 0) {
      return const [];
    }

    final esHoy = fechaYMD == fechaActual;
    final minutosActuales = (momento.hour * 60) + momento.minute;
    final rangosOcupados = <_Rango>[];

    for (final turno in occupied) {
      final inicio = _parseHora(turno['hora'] as String?);
      final duracion = _asInt(turno['servicio_duracion']);
      if (inicio == null || duracion == null || duracion <= 0) {
        continue;
      }
      rangosOcupados.add(_Rango(inicio, inicio + duracion));
    }

    final horarios = <String>[];
    for (
      var inicio = apertura;
      inicio + duracionServicio <= cierre;
      inicio += bloque
    ) {
      if (esHoy && inicio <= minutosActuales) {
        continue;
      }

      final fin = inicio + duracionServicio;
      final ocupado = rangosOcupados.any(
        (rango) => inicio < rango.fin && fin > rango.inicio,
      );

      if (!ocupado) {
        horarios.add(_formatHora(inicio));
      }
    }

    return horarios;
  }

  static bool isAvailable({
    required String fechaYMD,
    required String hora,
    required Map<String, dynamic> config,
    required Map<String, dynamic> service,
    required List<Map<String, dynamic>> occupied,
    DateTime? now,
  }) {
    return availableSlots(
      fechaYMD: fechaYMD,
      config: config,
      service: service,
      occupied: occupied,
      now: now,
    ).contains(hora);
  }

  static void validateConfig({
    required String apertura,
    required String cierre,
    required int duracionBloqueMinutos,
  }) {
    final inicio = _parseHora(apertura);
    final fin = _parseHora(cierre);
    if (inicio == null || fin == null) {
      throw const FormatException('Las horas deben tener formato HH:MM.');
    }
    if (inicio >= fin) {
      throw const FormatException('La apertura debe ser anterior al cierre.');
    }
    if (duracionBloqueMinutos <= 0) {
      throw const FormatException(
        'La duración de bloque debe ser mayor a cero.',
      );
    }
  }

  static int? _parseHora(String? hora) {
    if (hora == null) return null;
    final partes = hora.split(':');
    if (partes.length != 2) return null;
    final horas = int.tryParse(partes[0]);
    final minutos = int.tryParse(partes[1]);
    if (horas == null ||
        minutos == null ||
        horas < 0 ||
        horas > 23 ||
        minutos < 0 ||
        minutos > 59) {
      return null;
    }
    return (horas * 60) + minutos;
  }

  static String _formatHora(int minutos) {
    final horas = (minutos ~/ 60).toString().padLeft(2, '0');
    final resto = (minutos % 60).toString().padLeft(2, '0');
    return '$horas:$resto';
  }

  static String _fechaYMD(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio-$mes-$dia';
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class _Rango {
  final int inicio;
  final int fin;

  const _Rango(this.inicio, this.fin);
}
