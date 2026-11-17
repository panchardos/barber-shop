sealed class AuthEvent {
  const AuthEvent();
}

final class AuthIniciado extends AuthEvent {
  const AuthIniciado();
}

final class AuthLoginSolicitado extends AuthEvent {
  final String usuario;
  final String password;

  const AuthLoginSolicitado({required this.usuario, required this.password});
}

final class AuthLogoutSolicitado extends AuthEvent {
  const AuthLogoutSolicitado();
}
