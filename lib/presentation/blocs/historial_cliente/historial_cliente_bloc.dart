import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/obtener_historial_cliente.dart';
import '../../utils/demo_config.dart';
import 'historial_cliente_event.dart';
import 'historial_cliente_state.dart';

class HistorialClienteBloc
    extends Bloc<HistorialClienteEvent, HistorialClienteState> {
  final ObtenerHistorialClienteUseCase _obtenerHistorial;

  HistorialClienteBloc(this._obtenerHistorial)
    : super(const HistorialClienteInitial()) {
    on<HistorialClienteBuscado>(_onBuscado);
  }

  Future<void> _onBuscado(
    HistorialClienteBuscado event,
    Emitter<HistorialClienteState> emit,
  ) async {
    final telefono = event.telefono.trim();
    if (telefono.isEmpty) {
      emit(
        const HistorialClienteError(
          'Ingresá un teléfono para consultar el historial.',
        ),
      );
      return;
    }

    emit(const HistorialClienteLoading());
    await DemoConfig.pausa();
    try {
      final turnos = _obtenerHistorial.execute(telefono);
      emit(HistorialClienteLoaded(turnos));
    } catch (e) {
      emit(HistorialClienteError(e.toString()));
    }
  }
}
