class ServerAvailability {
  const ServerAvailability._();

  static List<String> availableSlots({
    required String fechaYMD,
    required Map<String, dynamic> config,
    required Map<String, dynamic> service,
    required List<Map<String, dynamic>> occupied,
    List<Map<String, dynamic>> bloqueos = const [],
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

    final pausaInicioRaw = config['pausa_inicio'] as String?;
    final pausaFinRaw = config['pausa_fin'] as String?;
    final fecha = DateTime.tryParse(fechaYMD);
    if (fecha == null) {
      throw const FormatException('La fecha debe tener formato YYYY-MM-DD.');
    }
    final diasLaborales = _parseDias(config['dias_laborales'] as String?);
    if (!diasLaborales.contains(fecha.weekday)) {
      return const [];
    }

    final pausa = _resolverPausa(
      apertura: apertura,
      cierre: cierre,
      pausaInicioRaw: pausaInicioRaw,
      pausaFinRaw: pausaFinRaw,
    );

    final momento = now ?? DateTime.now();
    final fechaActual = _fechaYMD(momento);
    if (fechaYMD.compareTo(fechaActual) < 0) {
      return const [];
    }

    if (bloqueos.any(
      (bloqueo) => (bloqueo['todo_el_dia'] as int? ?? 0) == 1,
    )) {
      return const [];
    }

    final esHoy = fechaYMD == fechaActual;
    final minutosActuales = (momento.hour * 60) + momento.minute;
    final rangosOcupados = <_Rango>[];
    if (pausa != null) {
      rangosOcupados.add(pausa);
    }

    for (final turno in occupied) {
      final inicio = _parseHora(turno['hora'] as String?);
      final duracion = _asInt(turno['servicio_duracion']);
      if (inicio == null || duracion == null || duracion <= 0) {
        continue;
      }
      rangosOcupados.add(_Rango(inicio, inicio + duracion));
    }

    for (final bloqueo in bloqueos) {
      if ((bloqueo['todo_el_dia'] as int? ?? 0) == 1) continue;
      final inicio = _parseHora(bloqueo['hora_inicio'] as String?);
      final fin = _parseHora(bloqueo['hora_fin'] as String?);
      if (inicio == null || fin == null || inicio >= fin) {
        throw const FormatException(
          'El bloqueo tiene un rango horario inválido.',
        );
      }
      rangosOcupados.add(_Rango(inicio, fin));
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
    List<Map<String, dynamic>> bloqueos = const [],
    DateTime? now,
  }) {
    return availableSlots(
      fechaYMD: fechaYMD,
      config: config,
      service: service,
      occupied: occupied,
      bloqueos: bloqueos,
      now: now,
    ).contains(hora);
  }

  static void validateConfig({
    required String apertura,
    required String cierre,
    required int duracionBloqueMinutos,
    String? pausaInicio,
    String? pausaFin,
    List<int>? diasLaborales,
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
    _resolverPausa(
      apertura: inicio,
      cierre: fin,
      pausaInicioRaw: pausaInicio,
      pausaFinRaw: pausaFin,
    );

    final dias = diasLaborales ?? const [1, 2, 3, 4, 5, 6, 7];
    if (dias.isEmpty || dias.any((dia) => dia < 1 || dia > 7)) {
      throw const FormatException(
        'Seleccioná al menos un día de atención válido.',
      );
    }
  }

  static List<int> _parseDias(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const [1, 2, 3, 4, 5, 6, 7];
    }
    final dias = value
        .split(',')
        .map((dia) => int.tryParse(dia.trim()))
        .whereType<int>()
        .where((dia) => dia >= 1 && dia <= 7)
        .toSet()
        .toList()
      ..sort();
    return dias.isEmpty ? const [1, 2, 3, 4, 5, 6, 7] : dias;
  }

  static _Rango? _resolverPausa({
    required int apertura,
    required int cierre,
    required String? pausaInicioRaw,
    required String? pausaFinRaw,
  }) {
    if (pausaInicioRaw == null && pausaFinRaw == null) {
      return null;
    }

    final inicio = pausaInicioRaw == null ? null : _parseHora(pausaInicioRaw);
    final fin = pausaFinRaw == null ? null : _parseHora(pausaFinRaw);
    if (inicio == null || fin == null) {
      throw const FormatException(
        'La pausa debe tener horas válidas en formato HH:MM.',
      );
    }
    if (inicio >= fin) {
      throw const FormatException('La pausa debe comenzar antes de terminar.');
    }
    if (inicio < apertura || fin > cierre) {
      throw const FormatException(
        'La pausa debe estar dentro del horario de atención.',
      );
    }
    return _Rango(inicio, fin);
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
