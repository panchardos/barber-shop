import '../entities/servicio.dart';

abstract class ServicioRepository {
  Future<void> save(Servicio servicio);
  Future<Servicio?> findById(String id);
  Future<void> updatePrecio(String id, double nuevoPrecio);
  Future<List<Servicio>> findAll();
}
