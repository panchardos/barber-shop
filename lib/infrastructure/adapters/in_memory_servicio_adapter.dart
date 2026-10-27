import '../../domain/entities/servicio.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/servicio_repository.dart';

class InMemoryServicioAdapter implements ServicioRepository {
  final List<Servicio> _servicios = [
    Servicio(
      id: '1',
      nombre: 'Corte Tradicional',
      duracionMinutos: 30,
      precio: 5000.0,
    ),
    Servicio(
      id: '2',
      nombre: 'Arreglo de Barba',
      duracionMinutos: 30,
      precio: 3000.0,
    ),
    Servicio(
      id: '3',
      nombre: 'Corte + Barba',
      duracionMinutos: 45,
      precio: 7500.0,
    ),
    Servicio(
      id: '4',
      nombre: 'Perfilado de Cejas',
      duracionMinutos: 15,
      precio: 2000.0,
    ),
  ];

  @override
  List<Servicio> findAll() {
    return List.unmodifiable(_servicios);
  }

  @override
  Servicio? findById(String id) {
    for (final servicio in _servicios) {
      if (servicio.id == id) {
        return servicio;
      }
    }
    return null;
  }

  @override
  Future<void> save(Servicio servicio) async {
    final index = _servicios.indexWhere((s) => s.id == servicio.id);
    if (index >= 0) {
      _servicios[index] = servicio;
    } else {
      _servicios.add(servicio);
    }
  }

  @override
  Future<void> updatePrecio(String id, double nuevoPrecio) async {
    final index = _servicios.indexWhere((s) => s.id == id);
    if (index < 0) {
      throw ServicioNotFoundException(id);
    }

    final s = _servicios[index];
    _servicios[index] = Servicio(
      id: s.id,
      nombre: s.nombre,
      duracionMinutos: s.duracionMinutos,
      precio: nuevoPrecio,
    );
  }
}
