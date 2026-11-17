import 'package:barber_shop_server/auth/auth_service.dart';
import 'package:test/test.dart';

void main() {
  group('AuthService', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService(
        adminUser: 'admin',
        adminPassword: 'clave-demo',
        tokenTtl: const Duration(minutes: 5),
      );
    });

    test('devuelve token con credenciales válidas', () {
      final token = auth.login('admin', 'clave-demo');

      expect(token, isNotNull);
      expect(auth.validate(token), isTrue);
    });

    test('rechaza credenciales inválidas', () {
      expect(auth.login('admin', 'otra'), isNull);
      expect(auth.login('otro', 'clave-demo'), isNull);
    });

    test('invalida el token al cerrar sesión', () {
      final token = auth.login('admin', 'clave-demo')!;

      auth.logout(token);

      expect(auth.validate(token), isFalse);
    });

    test('rechaza tokens desconocidos', () {
      expect(auth.validate('token-inventado'), isFalse);
      expect(auth.validate(null), isFalse);
    });
  });
}
