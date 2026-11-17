import '../../domain/ports/auth_repository.dart';

class IniciarSesionAdminUseCase {
  final AuthRepository _authRepository;

  IniciarSesionAdminUseCase(this._authRepository);

  Future<void> execute({required String usuario, required String password}) {
    return _authRepository.login(usuario: usuario, password: password);
  }
}
