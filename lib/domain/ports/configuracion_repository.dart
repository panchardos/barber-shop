abstract class ConfiguracionRepository {
  Future<void> saveHorarioAtencion({
    required String apertura, 
    required String cierre, 
    required int duracionBloqueMinutos,
  });
  
  Future<Map<String, dynamic>> getHorarioAtencion();
  
  Future<void> saveModoOscuro(bool esModoOscuro);
  
  Future<bool> getModoOscuro();
}