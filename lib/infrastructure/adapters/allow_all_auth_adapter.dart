import '../../domain/ports/auth_repository.dart';

/// Adaptador para el modo local/memoria: el panel admin no pide login.
/// En modo remoto se usa ApiAuthAdapter.
class AllowAllAuthAdapter implements AuthRepository {
  @override
  Future<void> login({
    required String usuario,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  bool get estaAutenticado => true;

  @override
  String? get token => null;
}
