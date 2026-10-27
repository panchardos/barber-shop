import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/cancelar_turno.dart';
import '../../../application/use_cases/obtener_turnos_por_dia.dart';
import '../../utils/date_formatters.dart';
import 'agenda_admin_event.dart';
import 'agenda_admin_state.dart';

class AgendaAdminBloc extends Bloc<AgendaAdminEvent, AgendaAdminState> {
  final ObtenerTurnosPorDiaUseCase _obtenerTurnos;
  final CancelarTurnoUseCase _cancelarTurno;

  AgendaAdminBloc(this._obtenerTurnos, this._cancelarTurno)
    : super(const AgendaAdminInitial()) {
    on<AgendaAdminCargada>(_onCargada);
    on<AgendaAdminFechaSeleccionada>(_onFechaSeleccionada);
    on<AgendaAdminTurnoCancelado>(_onTurnoCancelado);
    on<AgendaAdminRefrescada>(_onRefrescada);
    on<AgendaAdminMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onCargada(
    AgendaAdminCargada event,
    Emitter<AgendaAdminState> emit,
  ) async {
    final fecha = soloFecha(event.fecha ?? DateTime.now());
    emit(const AgendaAdminLoading());

    try {
      final turnos = _obtenerTurnos.execute(fechaYMD(fecha));
      emit(AgendaAdminLoaded(turnos: turnos, fecha: fecha));
    } catch (e) {
      emit(AgendaAdminError(e.toString()));
    }
  }

  Future<void> _onFechaSeleccionada(
    AgendaAdminFechaSeleccionada event,
    Emitter<AgendaAdminState> emit,
  ) async {
    final fecha = soloFecha(event.fecha);

    if (state is! AgendaAdminLoaded) {
      add(AgendaAdminCargada(fecha: fecha));
      return;
    }

    final actual = state as AgendaAdminLoaded;
    emit(
      actual.copyWith(
        fecha: fecha,
        turnos: const [],
        cargando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final turnos = _obtenerTurnos.execute(fechaYMD(fecha));
      emit(
        actual.copyWith(
          fecha: fecha,
          turnos: turnos,
          cargando: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        actual.copyWith(
          fecha: fecha,
          turnos: const [],
          cargando: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTurnoCancelado(
    AgendaAdminTurnoCancelado event,
    Emitter<AgendaAdminState> emit,
  ) async {
    final actual = state;
    if (actual is! AgendaAdminLoaded) return;

    emit(
      actual.copyWith(
        cancelando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _cancelarTurno.execute(event.turno.id);
      final turnos = _obtenerTurnos.execute(fechaYMD(actual.fecha));

      emit(
        actual.copyWith(
          turnos: turnos,
          cancelando: false,
          successMessage: 'Turno cancelado correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(cancelando: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefrescada(
    AgendaAdminRefrescada event,
    Emitter<AgendaAdminState> emit,
  ) async {
    final actual = state;
    if (actual is! AgendaAdminLoaded) {
      add(const AgendaAdminCargada());
      return;
    }

    emit(actual.copyWith(cargando: true, errorMessage: null));
    final turnos = _obtenerTurnos.execute(fechaYMD(actual.fecha));
    emit(actual.copyWith(turnos: turnos, cargando: false));
  }

  void _onMensajeLimpiado(
    AgendaAdminMensajeLimpiado event,
    Emitter<AgendaAdminState> emit,
  ) {
    final actual = state;
    if (actual is! AgendaAdminLoaded) return;
    if (actual.errorMessage == null && actual.successMessage == null) return;
    emit(actual.copyWith(errorMessage: null, successMessage: null));
  }
}
