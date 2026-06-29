import '../entities/servicio.dart';

abstract class ServicioRepository {
  void save(Servicio servicio);
  Servicio? findById(String id);
  void updatePrecio(String id, double nuevoPrecio);
  List<Servicio> findAll(); // NUEVO: Para obtener todo el catálogo
}