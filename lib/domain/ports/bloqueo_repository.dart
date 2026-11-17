import '../entities/bloqueo.dart';

abstract class BloqueoRepository {
  Future<void> save(Bloqueo bloqueo);
  Future<void> delete(String id);
  Future<List<Bloqueo>> findByDate(String fechaYMD);
}
