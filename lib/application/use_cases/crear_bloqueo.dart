import '../../domain/entities/bloqueo.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/bloqueo_repository.dart';

class CrearBloqueoUseCase {
  final BloqueoRepository _bloqueoRepository;

  static int _secuencia = 0;

  CrearBloqueoUseCase(this._bloqueoRepository);

  Future<String> execute({
    required String fechaYMD,
    required bool todoElDia,
    String? horaInicio,
    String? horaFin,
    String? motivo,
  }) async {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(fechaYMD.trim())) {
      throw BloqueoInvalidoException(
        'La fecha debe tener formato YYYY-MM-DD.',
      );
    }

    final inicio = todoElDia ? null : _normalizarHora(horaInicio);
    final fin = todoElDia ? null : _normalizarHora(horaFin);
    final motivoLimpio = (motivo == null || motivo.trim().isEmpty)
        ? null
        : motivo.trim();

    if (!todoElDia) {
      if (inicio == null || fin == null) {
        throw BloqueoInvalidoException(
          'Indicá hora de inicio y de fin, o marcá todo el día.',
        );
      }
      final inicioMin = _horaAMinutos(inicio);
      final finMin = _horaAMinutos(fin);
      if (inicioMin == null || finMin == null) {
        throw BloqueoInvalidoException(
          'Las horas del bloqueo deben tener formato HH:MM.',
        );
      }
      if (inicioMin >= finMin) {
        throw BloqueoInvalidoException(
          'El bloqueo debe comenzar antes de terminar.',
        );
      }
    }

    _secuencia++;
    final id = 'BLQ-${DateTime.now().microsecondsSinceEpoch}-$_secuencia';

    await _bloqueoRepository.save(
      Bloqueo(
        id: id,
        fechaYMD: fechaYMD.trim(),
        todoElDia: todoElDia,
        horaInicio: inicio,
        horaFin: fin,
        motivo: motivoLimpio,
      ),
    );

    return id;
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
}
