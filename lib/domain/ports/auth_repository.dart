abstract class AuthRepository {
  Future<void> login({required String usuario, required String password});

  Future<void> logout();

  bool get estaAutenticado;

  String? get token;
}
