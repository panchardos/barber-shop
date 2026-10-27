import '../entities/servicio.dart';

abstract class ServicioRepository {
  Future<void> save(Servicio servicio);
  Servicio? findById(String id);
  Future<void> updatePrecio(String id, double nuevoPrecio);
  List<Servicio> findAll(); // Para obtener todo el catálogo
}
