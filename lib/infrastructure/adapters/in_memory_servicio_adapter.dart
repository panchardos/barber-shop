import '../../domain/entities/servicio.dart';
import '../../domain/ports/servicio_repository.dart';

class InMemoryServicioAdapter implements ServicioRepository {
  // Usamos un Map para buscar rápido por ID
  final Map<String, Servicio> _dbServicios = {};

  @override
  void save(Servicio servicio) {
    _dbServicios[servicio.id] = servicio;
  }

  @override
  Servicio? findById(String id) {
    return _dbServicios[id];
  }

  @override
  void updatePrecio(String id, double nuevoPrecio) {
    if (_dbServicios.containsKey(id)) {
      _dbServicios[id]!.precio = nuevoPrecio;
      print(" [DB Servicios] Precio actualizado para $id: \$${nuevoPrecio}");
    }
  }
}