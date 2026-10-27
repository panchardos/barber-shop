import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/agendar_turno.dart';
import '../../../application/use_cases/obtener_catalogo_servicios.dart';
import '../../../application/use_cases/obtener_horarios_disponibles.dart';
import '../../utils/date_formatters.dart';
import 'reserva_event.dart';
import 'reserva_state.dart';

class ReservaBloc extends Bloc<ReservaEvent, ReservaState> {
  final ObtenerCatalogoServiciosUseCase _obtenerCatalogo;
  final ObtenerHorariosDisponiblesUseCase _obtenerHorarios;
  final AgendarTurnoUseCase _agendarTurno;

  ReservaBloc(this._obtenerCatalogo, this._obtenerHorarios, this._agendarTurno)
    : super(const ReservaInitial()) {
    on<ReservaIniciada>(_onIniciada);
    on<ReservaServicioSeleccionado>(_onServicioSeleccionado);
    on<ReservaFechaSeleccionada>(_onFechaSeleccionada);
    on<ReservaHorarioSeleccionado>(_onHorarioSeleccionado);
    on<ReservaConfirmada>(_onConfirmada);
    on<ReservaMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onIniciada(
    ReservaIniciada event,
    Emitter<ReservaState> emit,
  ) async {
    final fecha = soloFecha(event.fecha);
    emit(const ReservaLoading());

    try {
      final servicios = _obtenerCatalogo.execute();
      if (servicios.isEmpty) {
        emit(const ReservaError('No hay servicios disponibles.'));
        return;
      }

      final servicio = servicios.first;
      final horarios = await _obtenerHorarios.execute(
        fechaYMD: fechaYMD(fecha),
        servicio: servicio,
      );

      emit(
        ReservaLoaded(
          servicios: servicios,
          servicioSeleccionado: servicio,
          fecha: fecha,
          horarios: horarios,
          horaSeleccionada: null,
        ),
      );
    } catch (e) {
      emit(ReservaError(e.toString()));
    }
  }

  Future<void> _onServicioSeleccionado(
    ReservaServicioSeleccionado event,
    Emitter<ReservaState> emit,
  ) async {
    final actual = state;
    if (actual is! ReservaLoaded) return;

    final base = actual.copyWith(
      servicioSeleccionado: event.servicio,
      horarios: const [],
      horaSeleccionada: null,
      cargandoHorarios: true,
      errorMessage: null,
    );
    emit(base);

    try {
      final horarios = await _obtenerHorarios.execute(
        fechaYMD: fechaYMD(base.fecha),
        servicio: event.servicio,
      );
      emit(base.copyWith(horarios: horarios, cargandoHorarios: false));
    } catch (e) {
      emit(base.copyWith(cargandoHorarios: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFechaSeleccionada(
    ReservaFechaSeleccionada event,
    Emitter<ReservaState> emit,
  ) async {
    final actual = state;
    if (actual is! ReservaLoaded || actual.servicioSeleccionado == null) {
      return;
    }

    final fecha = soloFecha(event.fecha);
    final base = actual.copyWith(
      fecha: fecha,
      horarios: const [],
      horaSeleccionada: null,
      cargandoHorarios: true,
      errorMessage: null,
    );
    emit(base);

    try {
      final horarios = await _obtenerHorarios.execute(
        fechaYMD: fechaYMD(fecha),
        servicio: actual.servicioSeleccionado!,
      );
      emit(base.copyWith(horarios: horarios, cargandoHorarios: false));
    } catch (e) {
      emit(base.copyWith(cargandoHorarios: false, errorMessage: e.toString()));
    }
  }

  void _onHorarioSeleccionado(
    ReservaHorarioSeleccionado event,
    Emitter<ReservaState> emit,
  ) {
    final actual = state;
    if (actual is! ReservaLoaded) return;
    emit(actual.copyWith(horaSeleccionada: event.hora, errorMessage: null));
  }

  Future<void> _onConfirmada(
    ReservaConfirmada event,
    Emitter<ReservaState> emit,
  ) async {
    final actual = state;
    if (actual is! ReservaLoaded) return;

    if (actual.servicioSeleccionado == null ||
        actual.horaSeleccionada == null) {
      emit(
        actual.copyWith(errorMessage: 'Seleccioná un servicio y un horario.'),
      );
      return;
    }

    final servicio = actual.servicioSeleccionado!;
    final hora = actual.horaSeleccionada!;
    emit(actual.copyWith(enviando: true, errorMessage: null));

    try {
      await _agendarTurno.execute(
        nombreCliente: event.nombre,
        telefonoCliente: event.telefono,
        servicioSeleccionado: servicio,
        fechaYMD: fechaYMD(actual.fecha),
        hora: hora,
      );

      emit(
        ReservaSuccess(
          servicio: servicio,
          fecha: actual.fecha,
          hora: hora,
          nombre: event.nombre,
        ),
      );
    } catch (e) {
      emit(actual.copyWith(enviando: false, errorMessage: e.toString()));
    }
  }

  void _onMensajeLimpiado(
    ReservaMensajeLimpiado event,
    Emitter<ReservaState> emit,
  ) {
    final actual = state;
    if (actual is! ReservaLoaded || actual.errorMessage == null) return;
    emit(actual.copyWith(errorMessage: null));
  }
}
