import '../entities/turno.dart';

abstract class TurnoRepository {
  Future<void> save(Turno turno);
  Future<List<Turno>> findByDate(String fechaYMD);
  Future<void> cancelar(String id);
  Future<List<Turno>> findByClienteTelefono(String telefono);
}
