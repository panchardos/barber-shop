import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'admin_login_page.dart';

class AdminGate extends StatelessWidget {
  final Widget child;

  const AdminGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated() => child,
          AuthUnauthenticated() ||
          AuthError() ||
          AuthLoading() => const AdminLoginPage(),
          AuthInitial() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        };
      },
    );
  }
}
