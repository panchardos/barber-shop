import '../../domain/entities/servicio.dart';
import '../../domain/ports/servicio_repository.dart';

class ObtenerCatalogoServiciosUseCase {
  final ServicioRepository _servicioRepository;

  ObtenerCatalogoServiciosUseCase(this._servicioRepository);

  List<Servicio> execute() {
    final catalogo = _servicioRepository.findAll();
    if (catalogo.isEmpty) {
      print(" ⚠️ [Caso de Uso] Advertencia: El catálogo de servicios está vacío.");
    }
    return catalogo;
  }
}