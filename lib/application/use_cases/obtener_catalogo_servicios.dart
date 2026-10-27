import '../../domain/entities/servicio.dart';
import '../../domain/ports/servicio_repository.dart';

class ObtenerCatalogoServiciosUseCase {
  final ServicioRepository _servicioRepository;

  ObtenerCatalogoServiciosUseCase(this._servicioRepository);

  List<Servicio> execute() {
    return _servicioRepository.findAll();
  }
}
