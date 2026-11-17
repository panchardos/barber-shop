import '../../domain/ports/auth_repository.dart';

class VerificarSesionAdminUseCase {
  final AuthRepository _authRepository;

  VerificarSesionAdminUseCase(this._authRepository);

  bool execute() {
    return _authRepository.estaAutenticado;
  }
}
