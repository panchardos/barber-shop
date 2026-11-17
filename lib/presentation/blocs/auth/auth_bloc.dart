import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/cerrar_sesion_admin.dart';
import '../../../application/use_cases/iniciar_sesion_admin.dart';
import '../../../application/use_cases/verificar_sesion_admin.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IniciarSesionAdminUseCase _iniciarSesion;
  final CerrarSesionAdminUseCase _cerrarSesion;
  final VerificarSesionAdminUseCase _verificarSesion;

  AuthBloc(this._iniciarSesion, this._cerrarSesion, this._verificarSesion)
    : super(const AuthInitial()) {
    on<AuthIniciado>(_onIniciado);
    on<AuthLoginSolicitado>(_onLogin);
    on<AuthLogoutSolicitado>(_onLogout);
  }

  Future<void> _onIniciado(AuthIniciado event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final autenticado = _verificarSesion.execute();
      emit(
        autenticado ? const AuthAuthenticated() : const AuthUnauthenticated(),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(
    AuthLoginSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _iniciarSesion.execute(
        usuario: event.usuario,
        password: event.password,
      );
      emit(const AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutSolicitado event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _cerrarSesion.execute();
    } catch (_) {
      // El token local se limpia igual en el adaptador.
    }
    emit(const AuthUnauthenticated());
  }
}
