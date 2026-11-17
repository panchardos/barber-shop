import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/crear_bloqueo.dart';
import '../../../application/use_cases/eliminar_bloqueo.dart';
import '../../../application/use_cases/obtener_bloqueos_por_dia.dart';
import '../../utils/date_formatters.dart';
import '../../utils/demo_config.dart';
import 'bloqueos_admin_event.dart';
import 'bloqueos_admin_state.dart';

class BloqueosAdminBloc
    extends Bloc<BloqueosAdminEvent, BloqueosAdminState> {
  final ObtenerBloqueosPorDiaUseCase _obtenerBloqueos;
  final CrearBloqueoUseCase _crearBloqueo;
  final EliminarBloqueoUseCase _eliminarBloqueo;

  BloqueosAdminBloc(
    this._obtenerBloqueos,
    this._crearBloqueo,
    this._eliminarBloqueo,
  ) : super(const BloqueosAdminInitial()) {
    on<BloqueosAdminCargados>(_onCargados);
    on<BloqueoAgregado>(_onAgregado);
    on<BloqueoEliminado>(_onEliminado);
    on<BloqueosAdminMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onCargados(
    BloqueosAdminCargados event,
    Emitter<BloqueosAdminState> emit,
  ) async {
    final fecha = soloFecha(event.fecha);
    emit(const BloqueosAdminLoading());
    await DemoConfig.pausa();
    try {
      final bloqueos = await _obtenerBloqueos.execute(fechaYMD(fecha));
      emit(BloqueosAdminLoaded(bloqueos: bloqueos, fecha: fecha));
    } catch (e) {
      emit(BloqueosAdminError(e.toString()));
    }
  }

  Future<void> _onAgregado(
    BloqueoAgregado event,
    Emitter<BloqueosAdminState> emit,
  ) async {
    final actual = state;
    if (actual is! BloqueosAdminLoaded) return;

    emit(
      actual.copyWith(
        guardando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    await DemoConfig.pausa();

    try {
      await _crearBloqueo.execute(
        fechaYMD: fechaYMD(event.fecha),
        todoElDia: event.todoElDia,
        horaInicio: event.horaInicio,
        horaFin: event.horaFin,
        motivo: event.motivo,
      );
      final bloqueos = await _obtenerBloqueos.execute(
        fechaYMD(actual.fecha),
      );
      emit(
        actual.copyWith(
          bloqueos: bloqueos,
          guardando: false,
          successMessage: 'Bloqueo agregado correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(guardando: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onEliminado(
    BloqueoEliminado event,
    Emitter<BloqueosAdminState> emit,
  ) async {
    final actual = state;
    if (actual is! BloqueosAdminLoaded) return;

    emit(
      actual.copyWith(
        eliminando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    await DemoConfig.pausa();

    try {
      await _eliminarBloqueo.execute(event.id);
      final bloqueos = await _obtenerBloqueos.execute(
        fechaYMD(actual.fecha),
      );
      emit(
        actual.copyWith(
          bloqueos: bloqueos,
          eliminando: false,
          successMessage: 'Bloqueo eliminado correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(eliminando: false, errorMessage: e.toString()));
    }
  }

  void _onMensajeLimpiado(
    BloqueosAdminMensajeLimpiado event,
    Emitter<BloqueosAdminState> emit,
  ) {
    final actual = state;
    if (actual is! BloqueosAdminLoaded) return;
    if (actual.errorMessage == null && actual.successMessage == null) return;
    emit(actual.copyWith(errorMessage: null, successMessage: null));
  }
}
