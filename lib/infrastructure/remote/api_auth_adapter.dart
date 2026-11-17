import '../../domain/exceptions/domain_exceptions.dart';
import '../../domain/ports/auth_repository.dart';
import 'api_client.dart';
import 'auth_session.dart';

class ApiAuthAdapter implements AuthRepository {
  final ApiClient _client;
  final AuthSession _session;

  ApiAuthAdapter(this._client, this._session);

  @override
  Future<void> login({
    required String usuario,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        body: {'usuario': usuario, 'password': password},
      );

      if (response is! Map<String, dynamic> ||
          response['token'] is! String ||
          (response['token'] as String).isEmpty) {
        throw AuthenticationFailureException(
          'El servidor no devolvió un token válido.',
        );
      }

      _session.setToken(response['token'] as String);
    } on ApiClientException catch (error) {
      throw AuthenticationFailureException(error.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/api/auth/logout');
    } catch (_) {
      // El token local se limpia igual.
    } finally {
      _session.clear();
    }
  }

  @override
  bool get estaAutenticado => _session.isAuthenticated;

  @override
  String? get token => _session.token;
}
