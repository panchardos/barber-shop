import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_routes.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../theme/app_theme.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _ingresar(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginSolicitado(
        usuario: _usuarioCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final cargando = state is AuthLoading;
                  final error = state is AuthError ? state.message : null;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'LA NOTA BARBER SHOP',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.brand.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Acceso administrador',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.muted,
                            ),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: _usuarioCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ingresá el usuario';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _ingresar(context),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresá la contraseña';
                                }
                                return null;
                              },
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.rojo,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: cargando
                                  ? null
                                  : () => _ingresar(context),
                              child: cargando
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.blanco,
                                      ),
                                    )
                                  : const Text('INGRESAR'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: cargando
                                  ? null
                                  : () {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        AppRoutes.reserva,
                                        (route) => false,
                                      );
                                    },
                              child: const Text('Volver al sitio'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
