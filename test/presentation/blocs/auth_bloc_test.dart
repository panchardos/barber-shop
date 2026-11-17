import 'package:barber_shop/application/use_cases/cerrar_sesion_admin.dart';
import 'package:barber_shop/application/use_cases/iniciar_sesion_admin.dart';
import 'package:barber_shop/application/use_cases/verificar_sesion_admin.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_event.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('AuthBloc', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    AuthBloc crearBloc() {
      return AuthBloc(
        IniciarSesionAdminUseCase(repository),
        CerrarSesionAdminUseCase(repository),
        VerificarSesionAdminUseCase(repository),
      );
    }

    blocTest<AuthBloc, AuthState>(
      'inicia autenticado si la sesión ya existe',
      build: () {
        repository.autenticado = true;
        return crearBloc();
      },
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'inicia no autenticado sin sesión',
      build: crearBloc,
      act: (bloc) => bloc.add(const AuthIniciado()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'autentica con credenciales válidas',
      build: crearBloc,
      act: (bloc) => bloc.add(
        const AuthLoginSolicitado(usuario: 'admin', password: 'clave'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) {
        expect(repository.estaAutenticado, isTrue);
        expect(repository.token, isNotNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'informa error con credenciales inválidas',
      build: () {
        repository.failOnLogin = true;
        return crearBloc();
      },
      act: (bloc) => bloc.add(
        const AuthLoginSolicitado(usuario: 'admin', password: 'incorrecta'),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'cierra la sesión',
      build: () {
        repository.autenticado = true;
        return crearBloc();
      },
      act: (bloc) => bloc.add(const AuthLogoutSolicitado()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      verify: (_) {
        expect(repository.estaAutenticado, isFalse);
      },
    );
  });
}
