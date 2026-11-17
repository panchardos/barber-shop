import '../../domain/entities/servicio.dart';
import '../../domain/ports/servicio_repository.dart';

class ObtenerCatalogoServiciosUseCase {
  final ServicioRepository _servicioRepository;

  ObtenerCatalogoServiciosUseCase(this._servicioRepository);

  Future<List<Servicio>> execute() async {
    return await _servicioRepository.findAll();
  }
}
