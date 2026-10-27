import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/configurar_agenda.dart';
import 'configuracion_agenda_event.dart';
import 'configuracion_agenda_state.dart';

class ConfiguracionAgendaBloc
    extends Bloc<ConfiguracionAgendaEvent, ConfiguracionAgendaState> {
  final ConfigurarAgendaUseCase _configurarAgenda;

  ConfiguracionAgendaBloc(this._configurarAgenda)
    : super(const ConfiguracionAgendaInitial()) {
    on<ConfiguracionAgendaCargada>(_onCargada);
    on<ConfiguracionAgendaGuardada>(_onGuardada);
    on<ConfiguracionAgendaMensajeLimpiado>(_onMensajeLimpiado);
  }

  Future<void> _onCargada(
    ConfiguracionAgendaCargada event,
    Emitter<ConfiguracionAgendaState> emit,
  ) async {
    emit(const ConfiguracionAgendaLoading());
    try {
      final configuracion = await _configurarAgenda.obtenerHorario();
      emit(ConfiguracionAgendaLoaded(configuracion: configuracion));
    } catch (e) {
      emit(ConfiguracionAgendaError(e.toString()));
    }
  }

  Future<void> _onGuardada(
    ConfiguracionAgendaGuardada event,
    Emitter<ConfiguracionAgendaState> emit,
  ) async {
    final actual = state;
    if (actual is! ConfiguracionAgendaLoaded) return;

    emit(
      actual.copyWith(
        guardando: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _configurarAgenda.guardarHorario(
        apertura: event.apertura,
        cierre: event.cierre,
        duracionBloque: event.duracionBloque,
      );
      final configuracion = await _configurarAgenda.obtenerHorario();

      emit(
        ConfiguracionAgendaLoaded(
          configuracion: configuracion,
          successMessage: 'Configuración guardada correctamente.',
        ),
      );
    } catch (e) {
      emit(actual.copyWith(guardando: false, errorMessage: e.toString()));
    }
  }

  void _onMensajeLimpiado(
    ConfiguracionAgendaMensajeLimpiado event,
    Emitter<ConfiguracionAgendaState> emit,
  ) {
    final actual = state;
    if (actual is! ConfiguracionAgendaLoaded) return;
    if (actual.errorMessage == null && actual.successMessage == null) return;
    emit(actual.copyWith(errorMessage: null, successMessage: null));
  }
}
