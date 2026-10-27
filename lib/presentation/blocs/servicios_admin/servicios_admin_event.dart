sealed class ServiciosAdminEvent {
  const ServiciosAdminEvent();
}

final class ServiciosAdminCargados extends ServiciosAdminEvent {
  const ServiciosAdminCargados();
}

final class ServicioCreado extends ServiciosAdminEvent {
  final String nombre;
  final int duracionMinutos;
  final double precio;

  const ServicioCreado({
    required this.nombre,
    required this.duracionMinutos,
    required this.precio,
  });
}

final class PrecioServicioActualizado extends ServiciosAdminEvent {
  final String servicioId;
  final double precio;

  const PrecioServicioActualizado({
    required this.servicioId,
    required this.precio,
  });
}

final class ServiciosAdminMensajeLimpiado extends ServiciosAdminEvent {
  const ServiciosAdminMensajeLimpiado();
}
