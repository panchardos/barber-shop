import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/configuracion_repository.dart';

class ConfigurarAgendaUseCase {
  final ConfiguracionRepository _configRepository;

  ConfigurarAgendaUseCase(this._configRepository);

  Future<void> guardarHorario({
    required String apertura,
    required String cierre,
    required int duracionBloque,
    String? pausaInicio,
    String? pausaFin,
    Set<int>? diasLaborales,
  }) async {
    final inicio = _normalizarHora(pausaInicio);
    final fin = _normalizarHora(pausaFin);
    final dias = diasLaborales ?? ConfiguracionAgenda.diasLaboralesPorDefecto;
    if (dias.isEmpty || dias.any((dia) => dia < 1 || dia > 7)) {
      throw ConfiguracionInvalidaException(
        'Seleccioná al menos un día de atención válido.',
      );
    }

    if ((inicio == null) != (fin == null)) {
      throw ConfiguracionInvalidaException(
        'La pausa debe tener hora de inicio y de fin.',
      );
    }

    if (inicio != null && fin != null) {
      final aperturaMin = _horaAMinutos(apertura);
      final cierreMin = _horaAMinutos(cierre);
      final inicioMin = _horaAMinutos(inicio);
      final finMin = _horaAMinutos(fin);
      if (aperturaMin == null || cierreMin == null) {
        throw ConfiguracionInvalidaException(
          'Las horas de apertura y cierre deben tener formato HH:MM.',
        );
      }
      if (inicioMin == null || finMin == null) {
        throw ConfiguracionInvalidaException(
          'La pausa debe tener formato HH:MM.',
        );
      }
      if (inicioMin >= finMin) {
        throw ConfiguracionInvalidaException(
          'La pausa debe comenzar antes de terminar.',
        );
      }
      if (inicioMin < aperturaMin || finMin > cierreMin) {
        throw ConfiguracionInvalidaException(
          'La pausa debe estar dentro del horario de atención.',
        );
      }
    }

    await _configRepository.saveHorarioAtencion(
      ConfiguracionAgenda(
        apertura: apertura,
        cierre: cierre,
        duracionBloqueMinutos: duracionBloque,
        pausaInicio: inicio,
        pausaFin: fin,
        diasLaborales: dias,
      ),
    );
  }

  String? _normalizarHora(String? hora) {
    final valor = hora?.trim() ?? '';
    return valor.isEmpty ? null : valor;
  }

  int? _horaAMinutos(String hora) {
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

  Future<ConfiguracionAgenda> obtenerHorario() async {
    return await _configRepository.getHorarioAtencion();
  }
}
