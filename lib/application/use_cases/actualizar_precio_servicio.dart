import '../../domain/ports/servicio_repository.dart';

class ActualizarPrecioServicioUseCase {
  final ServicioRepository _servicioRepository;

  ActualizarPrecioServicioUseCase(this._servicioRepository);

  Future<void> execute(String idServicio, double nuevoPrecio) async {
    if (nuevoPrecio <= 0) {
      throw Exception("El precio debe ser un valor positivo.");
    }
    await _servicioRepository.updatePrecio(idServicio, nuevoPrecio);
  }
}
