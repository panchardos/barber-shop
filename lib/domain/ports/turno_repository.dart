import '../entities/turno.dart';

abstract class TurnoRepository {
  Future<void> save(Turno turno);
  bool existsAtTime(String fechaYMD, String hora);
  List<Turno> findByDate(String fechaYMD); // Para ver la agenda
  Future<void> delete(String id); // Para cancelar un turno

  List<Turno> findByClienteTelefono(String telefono); // HU 8 historial cliente
}
