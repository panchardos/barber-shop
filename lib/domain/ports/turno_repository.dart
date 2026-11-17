import '../entities/turno.dart';

abstract class TurnoRepository {
  Future<void> save(Turno turno);
  Future<bool> existsAtTime(String fechaYMD, String hora);
  Future<List<Turno>> findByDate(String fechaYMD);
  Future<void> delete(String id);
  Future<List<Turno>> findByClienteTelefono(String telefono);
}
