import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/ports/configuracion_repository.dart';
import '../../domain/exceptions/domain_exceptions.dart';

class SharedPreferencesConfigAdapter implements ConfiguracionRepository {
  final SharedPreferences _prefs;

  SharedPreferencesConfigAdapter(this._prefs);

  static const String _keyApertura = "cfg_apertura";
  static const String _keyCierre = "cfg_cierre";
  static const String _keyDuracion = "cfg_duracion_bloque";
  static const String _keyModoOscuro = "cfg_modo_oscuro";

  @override
  Future<void> saveHorarioAtencion({
    required String apertura,
    required String cierre,
    required int duracionBloqueMinutos,
  }) async {
    try {
      await _prefs.setString(_keyApertura, apertura);
      await _prefs.setString(_keyCierre, cierre);
      await _prefs.setInt(_keyDuracion, duracionBloqueMinutos);
    } catch (e) {
      throw ConfiguracionFailureException("No se pudo guardar la configuración de horario: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> getHorarioAtencion() async {
    try {
      return {
        'apertura': _prefs.getString(_keyApertura) ?? "09:00",
        'cierre': _prefs.getString(_keyCierre) ?? "20:00",
        'duracionBloqueMinutos': _prefs.getInt(_keyDuracion) ?? 30,
      };
    } catch (e) {
      throw ConfiguracionFailureException("No se pudo leer la configuración de horario: $e");
    }
  }

  @override
  Future<void> saveModoOscuro(bool esModoOscuro) async {
    try {
      await _prefs.setBool(_keyModoOscuro, esModoOscuro);
    } catch (e) {
      throw ConfiguracionFailureException("No se pudo guardar la preferencia de tema: $e");
    }
  }

  @override
  Future<bool> getModoOscuro() async {
    try {
      return _prefs.getBool(_keyModoOscuro) ?? false;
    } catch (e) {
      throw ConfiguracionFailureException("No se pudo leer la preferencia de tema: $e");
    }
  }
}