import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/configuracion_agenda.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/exceptions/domain_exceptions.dart';

class SharedPreferencesConfigAdapter implements ConfiguracionRepository {
  final SharedPreferences _prefs;

  SharedPreferencesConfigAdapter(this._prefs);

  static const String _keyApertura = "cfg_apertura";
  static const String _keyCierre = "cfg_cierre";
  static const String _keyDuracion = "cfg_duracion_bloque";
  static const String _keyPausaInicio = "cfg_pausa_inicio";
  static const String _keyPausaFin = "cfg_pausa_fin";
  static const String _keyDiasLaborales = "cfg_dias_laborales";
  static const String _keyModoOscuro = "cfg_modo_oscuro";

  @override
  Future<void> saveHorarioAtencion(ConfiguracionAgenda configuracion) async {
    try {
      await _prefs.setString(_keyApertura, configuracion.apertura);
      await _prefs.setString(_keyCierre, configuracion.cierre);
      await _prefs.setInt(_keyDuracion, configuracion.duracionBloqueMinutos);
      if (configuracion.pausaInicio == null) {
        await _prefs.remove(_keyPausaInicio);
      } else {
        await _prefs.setString(_keyPausaInicio, configuracion.pausaInicio!);
      }
      if (configuracion.pausaFin == null) {
        await _prefs.remove(_keyPausaFin);
      } else {
        await _prefs.setString(_keyPausaFin, configuracion.pausaFin!);
      }
      final dias = configuracion.diasLaborales.toList()..sort();
      await _prefs.setStringList(
        _keyDiasLaborales,
        dias.map((dia) => dia.toString()).toList(),
      );
    } catch (e) {
      throw ConfiguracionFailureException(
        "No se pudo guardar la configuración de horario: $e",
      );
    }
  }

  @override
  Future<ConfiguracionAgenda> getHorarioAtencion() async {
    try {
      final pausaInicio = _prefs.getString(_keyPausaInicio);
      final pausaFin = _prefs.getString(_keyPausaFin);
      final diasGuardados = _prefs.getStringList(_keyDiasLaborales);
      final dias = diasGuardados == null || diasGuardados.isEmpty
          ? ConfiguracionAgenda.diasLaboralesPorDefecto
          : diasGuardados
                .map(int.tryParse)
                .whereType<int>()
                .where((dia) => dia >= 1 && dia <= 7)
                .toSet();
      return ConfiguracionAgenda(
        apertura: _prefs.getString(_keyApertura) ?? "09:00",
        cierre: _prefs.getString(_keyCierre) ?? "20:00",
        duracionBloqueMinutos: _prefs.getInt(_keyDuracion) ?? 30,
        pausaInicio: (pausaInicio == null || pausaInicio.isEmpty)
            ? null
            : pausaInicio,
        pausaFin: (pausaFin == null || pausaFin.isEmpty) ? null : pausaFin,
        diasLaborales: dias.isEmpty
            ? ConfiguracionAgenda.diasLaboralesPorDefecto
            : dias,
      );
    } catch (e) {
      throw ConfiguracionFailureException(
        "No se pudo leer la configuración de horario: $e",
      );
    }
  }

  @override
  Future<void> saveModoOscuro(bool esModoOscuro) async {
    try {
      await _prefs.setBool(_keyModoOscuro, esModoOscuro);
    } catch (e) {
      throw ConfiguracionFailureException(
        "No se pudo guardar la preferencia de tema: $e",
      );
    }
  }

  @override
  Future<bool> getModoOscuro() async {
    try {
      return _prefs.getBool(_keyModoOscuro) ?? false;
    } catch (e) {
      throw ConfiguracionFailureException(
        "No se pudo leer la preferencia de tema: $e",
      );
    }
  }
}
