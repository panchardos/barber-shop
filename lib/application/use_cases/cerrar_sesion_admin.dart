import '../../domain/ports/auth_repository.dart';

class CerrarSesionAdminUseCase {
  final AuthRepository _authRepository;

  CerrarSesionAdminUseCase(this._authRepository);

  Future<void> execute() {
    return _authRepository.logout();
  }
}
