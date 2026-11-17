import 'dart:convert';
import 'dart:math';

class AuthService {
  final String adminUser;
  final String adminPassword;
  final Duration tokenTtl;

  final Map<String, DateTime> _tokens = {};

  AuthService({
    required this.adminUser,
    required this.adminPassword,
    required this.tokenTtl,
  });

  String? login(String usuario, String password) {
    if (usuario != adminUser || password != adminPassword) {
      return null;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final token = base64UrlEncode(bytes);

    _tokens[token] = DateTime.now().add(tokenTtl);
    return token;
  }

  bool validate(String? token) {
    if (token == null || token.isEmpty) return false;

    final expira = _tokens[token];
    if (expira == null) return false;

    if (DateTime.now().isAfter(expira)) {
      _tokens.remove(token);
      return false;
    }

    return true;
  }

  void logout(String? token) {
    if (token == null) return;
    _tokens.remove(token);
  }

  DateTime? expiryFor(String token) => _tokens[token];
}
