import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/actualizar_precio_servicio.dart';
import '../../../application/use_cases/crear_servicio.dart';
import '../../../application/use_cases/obtener_catalogo_servicios.dart';
import 'servicios_admin_event.dart';
import 'servicios_admin_state.dart';

class ServiciosAdminBloc
    extends Bloc<ServiciosAdminEvent, ServiciosAdminState> {
  final ObtenerCatalogoServiciosUseCase _obtenerCatalogo;
  final CrearServicioUseCase _crearServicio;
  final ActualizarPrecioServicioUseCase _actualizarPrecio;

  ServiciosAdminBloc(
    this._obtenerCatalogo,
    this._crearServicio,
    this._actualizarPrecio,
  ) : super(const ServiciosAdminInitial()) {
    on<ServiciosAdminCargados>(_onCargados);
    on<ServicioCreado>(_onServicioCreado);
    on<PrecioServicioActualizado>(_onPrecioActualizado);
    on<ServiciosAdminMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onCargados(
    ServiciosAdminCargados event,
    Emitter<ServiciosAdminState> emit,
  ) async {
    emit(const ServiciosAdminLoading());
    try {
      final servicios = _obtenerCatalogo.execute();
      emit(ServiciosAdminLoaded(servicios: servicios));
    } catch (e) {
      emit(ServiciosAdminError(e.toString()));
    }
  }

  Future<void> _onServicioCreado(
    ServicioCreado event,
    Emitter<ServiciosAdminState> emit,
  ) async {
    final actual = _estadoBase();
    emit(
      actual.copyWith(
        guardando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _crearServicio.execute(
        nombre: event.nombre,
        duracionMinutos: event.duracionMinutos,
        precio: event.precio,
      );
      final servicios = _obtenerCatalogo.execute();

      emit(
        ServiciosAdminLoaded(
          servicios: servicios,
          successMessage: 'Servicio creado correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(guardando: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onPrecioActualizado(
    PrecioServicioActualizado event,
    Emitter<ServiciosAdminState> emit,
  ) async {
    final actual = _estadoBase();
    emit(
      actual.copyWith(
        guardando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _actualizarPrecio.execute(event.servicioId, event.precio);
      final servicios = _obtenerCatalogo.execute();

      emit(
        ServiciosAdminLoaded(
          servicios: servicios,
          successMessage: 'Precio actualizado correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(guardando: false, errorMessage: e.toString()));
    }
  }

  void _onMensajeLimpiado(
    ServiciosAdminMensajeLimpiado event,
    Emitter<ServiciosAdminState> emit,
  ) {
    final actual = state;
    if (actual is! ServiciosAdminLoaded) return;
    if (actual.errorMessage == null && actual.successMessage == null) return;
    emit(actual.copyWith(errorMessage: null, successMessage: null));
  }

  ServiciosAdminLoaded _estadoBase() {
    final actual = state;
    if (actual is ServiciosAdminLoaded) {
      return actual;
    }
    return ServiciosAdminLoaded(servicios: _obtenerCatalogo.execute());
  }
}
