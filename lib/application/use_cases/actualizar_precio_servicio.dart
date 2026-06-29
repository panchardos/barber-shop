import '../../domain/ports/servicio_repository.dart';

class ActualizarPrecioServicioUseCase {
  final ServicioRepository _servicioRepository;

  ActualizarPrecioServicioUseCase(this._servicioRepository);

  void execute(String idServicio, double nuevoPrecio) {
    if (nuevoPrecio <= 0) {
      throw Exception("El precio debe ser un valor positivo.");
    }
    _servicioRepository.updatePrecio(idServicio, nuevoPrecio);
  }
}