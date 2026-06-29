import '../entities/turno.dart';

abstract class TurnoRepository {
  void save(Turno turno);
  bool existsAtTime(String fechaYMD, String hora);
  List<Turno> findByDate(String fechaYMD); // Para ver la agenda
  void delete(String id);                  // Para cancelar un turno
}