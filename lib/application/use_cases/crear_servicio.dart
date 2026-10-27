import '../../domain/entities/servicio.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/servicio_repository.dart';

class CrearServicioUseCase {
  final ServicioRepository _servicioRepository;

  static int _secuencia = 0;

  CrearServicioUseCase(this._servicioRepository);

  Future<String> execute({
    required String nombre,
    required int duracionMinutos,
    required double precio,
  }) async {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      throw ServicioInvalidoException("El nombre es obligatorio.");
    }
    if (duracionMinutos <= 0) {
      throw ServicioInvalidoException("La duración debe ser mayor a cero.");
    }
    if (precio <= 0) {
      throw ServicioInvalidoException("El precio debe ser mayor a cero.");
    }

    _secuencia++;
    final id = "SRV-${DateTime.now().microsecondsSinceEpoch}-$_secuencia";
    final servicio = Servicio(
      id: id,
      nombre: nombreLimpio,
      duracionMinutos: duracionMinutos,
      precio: precio,
    );

    await _servicioRepository.save(servicio);

    return id;
  }
}
