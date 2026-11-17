import '../entities/bloqueo.dart';
import '../entities/configuracion_agenda.dart';
import '../entities/servicio.dart';
import '../entities/turno.dart';
import '../exceptions/domain_exceptions.dart';

class DisponibilidadHorariaService {
  const DisponibilidadHorariaService();

  List<String> calcularHorariosDisponibles({
    required String fechaYMD,
    required ConfiguracionAgenda configuracion,
    required Servicio servicio,
    required List<Turno> turnosDelDia,
    List<Bloqueo> bloqueos = const [],
    DateTime? ahora,
  }) {
    final apertura = _parseHora(configuracion.apertura);
    final cierre = _parseHora(configuracion.cierre);

    if (apertura == null || cierre == null) {
      throw ConfiguracionInvalidaException(
        'Las horas de apertura y cierre deben tener formato HH:MM.',
      );
    }
    if (apertura >= cierre) {
      throw ConfiguracionInvalidaException(
        'La hora de apertura debe ser anterior a la de cierre.',
      );
    }
    if (configuracion.duracionBloqueMinutos <= 0) {
      throw ConfiguracionInvalidaException(
        'La duración de bloque debe ser mayor a cero.',
      );
    }
    if (servicio.duracionMinutos <= 0) {
      throw ConfiguracionInvalidaException(
        'La duración del servicio debe ser mayor a cero.',
      );
    }

    final fecha = DateTime.tryParse(fechaYMD);
    if (fecha == null) {
      throw ConfiguracionInvalidaException(
        'La fecha debe tener formato YYYY-MM-DD.',
      );
    }
    if (!configuracion.esDiaLaboral(fecha.weekday)) {
      return const [];
    }

    final pausa = _resolverPausa(configuracion, apertura, cierre);

    final bloqueosDelDia = bloqueos
        .where((bloqueo) => bloqueo.fechaYMD == fechaYMD)
        .toList();
    if (bloqueosDelDia.any((bloqueo) => bloqueo.todoElDia)) {
      return const [];
    }

    final momentoActual = ahora ?? DateTime.now();
    final fechaActual = _formatearFecha(momentoActual);

    if (fechaYMD.compareTo(fechaActual) < 0) {
      return const [];
    }

    final esHoy = fechaYMD == fechaActual;
    final minutosActuales = momentoActual.hour * 60 + momentoActual.minute;
    final rangosOcupados = <_Rango>[];
    if (pausa != null) {
      rangosOcupados.add(pausa);
    }

    for (final bloqueo in bloqueosDelDia) {
      if (bloqueo.todoElDia) continue;
      final inicio = _parseHora(bloqueo.horaInicio ?? '');
      final fin = _parseHora(bloqueo.horaFin ?? '');
      if (inicio == null || fin == null || inicio >= fin) {
        throw BloqueoInvalidoException(
          'El bloqueo ${bloqueo.id} tiene un rango horario inválido.',
        );
      }
      rangosOcupados.add(_Rango(inicio, fin));
    }

    for (final turno in turnosDelDia) {
      final inicio = _parseHora(turno.hora);
      final duracion = turno.servicio.duracionMinutos;
      if (inicio == null || duracion <= 0) {
        continue;
      }
      rangosOcupados.add(_Rango(inicio, inicio + duracion));
    }

    final horarios = <String>[];
    for (
      var inicio = apertura;
      inicio + servicio.duracionMinutos <= cierre;
      inicio += configuracion.duracionBloqueMinutos
    ) {
      if (esHoy && inicio <= minutosActuales) {
        continue;
      }

      final fin = inicio + servicio.duracionMinutos;
      final ocupado = rangosOcupados.any(
        (rango) => inicio < rango.fin && fin > rango.inicio,
      );

      if (!ocupado) {
        horarios.add(_formatearHora(inicio));
      }
    }

    return horarios;
  }

  bool estaDisponible({
    required String fechaYMD,
    required String hora,
    required ConfiguracionAgenda configuracion,
    required Servicio servicio,
    required List<Turno> turnosDelDia,
    List<Bloqueo> bloqueos = const [],
    DateTime? ahora,
  }) {
    final horarios = calcularHorariosDisponibles(
      fechaYMD: fechaYMD,
      configuracion: configuracion,
      servicio: servicio,
      turnosDelDia: turnosDelDia,
      bloqueos: bloqueos,
      ahora: ahora,
    );
    return horarios.contains(hora);
  }

  _Rango? _resolverPausa(
    ConfiguracionAgenda configuracion,
    int apertura,
    int cierre,
  ) {
    final inicioConfig = configuracion.pausaInicio;
    final finConfig = configuracion.pausaFin;
    if (inicioConfig == null && finConfig == null) {
      return null;
    }

    final inicio = inicioConfig == null ? null : _parseHora(inicioConfig);
    final fin = finConfig == null ? null : _parseHora(finConfig);
    if (inicio == null || fin == null) {
      throw ConfiguracionInvalidaException(
        'La pausa debe tener horas válidas en formato HH:MM.',
      );
    }
    if (inicio >= fin) {
      throw ConfiguracionInvalidaException(
        'La pausa debe comenzar antes de terminar.',
      );
    }
    if (inicio < apertura || fin > cierre) {
      throw ConfiguracionInvalidaException(
        'La pausa debe estar dentro del horario de atención.',
      );
    }

    return _Rango(inicio, fin);
  }

  int? _parseHora(String hora) {
    final partes = hora.split(':');
    if (partes.length != 2) {
      return null;
    }

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

  String _formatearHora(int minutos) {
    final horas = (minutos ~/ 60).toString().padLeft(2, '0');
    final resto = (minutos % 60).toString().padLeft(2, '0');
    return '$horas:$resto';
  }

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio-$mes-$dia';
  }
}

class _Rango {
  final int inicio;
  final int fin;

  const _Rango(this.inicio, this.fin);
}
