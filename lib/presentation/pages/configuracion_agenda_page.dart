import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../blocs/configuracion_agenda/configuracion_agenda_bloc.dart';
import '../blocs/configuracion_agenda/configuracion_agenda_event.dart';
import '../blocs/configuracion_agenda/configuracion_agenda_state.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class ConfiguracionAgendaPage extends StatelessWidget {
  const ConfiguracionAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ConfiguracionAgendaBloc>()
            ..add(const ConfiguracionAgendaCargada()),
      child: const _ConfiguracionAgendaView(),
    );
  }
}

class _ConfiguracionAgendaView extends StatefulWidget {
  const _ConfiguracionAgendaView();

  @override
  State<_ConfiguracionAgendaView> createState() =>
      _ConfiguracionAgendaViewState();
}

class _ConfiguracionAgendaViewState extends State<_ConfiguracionAgendaView> {
  final _formKey = GlobalKey<FormState>();
  final _aperturaCtrl = TextEditingController();
  final _cierreCtrl = TextEditingController();
  final _intervaloCtrl = TextEditingController();

  @override
  void dispose() {
    _aperturaCtrl.dispose();
    _cierreCtrl.dispose();
    _intervaloCtrl.dispose();
    super.dispose();
  }

  String? _validarHora(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese una hora';
    }
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(value.trim())) {
      return 'Use el formato HH:MM';
    }
    return null;
  }

  String? _validarDuracion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el intervalo';
    }
    final numero = int.tryParse(value.trim());
    if (numero == null || numero <= 0) {
      return 'Debe ser un número mayor a 0';
    }
    return null;
  }

  int? _horaAMinutos(String hora) {
    final partes = hora.split(':');
    if (partes.length != 2) return null;
    final horas = int.tryParse(partes[0]);
    final minutos = int.tryParse(partes[1]);
    if (horas == null || minutos == null) return null;
    return (horas * 60) + minutos;
  }

  void _guardarConfiguracion(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final apertura = _aperturaCtrl.text.trim();
    final cierre = _cierreCtrl.text.trim();
    final aperturaMinutos = _horaAMinutos(apertura);
    final cierreMinutos = _horaAMinutos(cierre);

    if (aperturaMinutos == null ||
        cierreMinutos == null ||
        aperturaMinutos >= cierreMinutos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de apertura debe ser anterior a la de cierre'),
          backgroundColor: AppColors.rojo,
        ),
      );
      return;
    }

    context.read<ConfiguracionAgendaBloc>().add(
      ConfiguracionAgendaGuardada(
        apertura: apertura,
        cierre: cierre,
        duracionBloque: int.parse(_intervaloCtrl.text.trim()),
      ),
    );
  }

  void _cargarControles(ConfiguracionAgendaLoaded state) {
    final apertura = state.configuracion.apertura;
    final cierre = state.configuracion.cierre;
    final duracion = state.configuracion.duracionBloqueMinutos.toString();

    if (_aperturaCtrl.text != apertura) {
      _aperturaCtrl.text = apertura;
    }
    if (_cierreCtrl.text != cierre) {
      _cierreCtrl.text = cierre;
    }
    if (_intervaloCtrl.text != duracion) {
      _intervaloCtrl.text = duracion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
      listenWhen: (previous, current) =>
          current is ConfiguracionAgendaLoaded &&
          (previous is! ConfiguracionAgendaLoaded ||
              current.errorMessage != null ||
              current.successMessage != null),
      listener: (context, state) {
        if (state is! ConfiguracionAgendaLoaded) return;

        if (state.errorMessage != null || state.successMessage != null) {
          final mensaje = state.errorMessage ?? state.successMessage!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensaje)));
          context.read<ConfiguracionAgendaBloc>().add(
            const ConfiguracionAgendaMensajeLimpiado(),
          );
          return;
        }

        _cargarControles(state);
      },
      child: BlocBuilder<ConfiguracionAgendaBloc, ConfiguracionAgendaState>(
        builder: (context, state) {
          return AdminScaffold(
            selected: AdminSection.configuracion,
            body: switch (state) {
              ConfiguracionAgendaInitial() || ConfiguracionAgendaLoading() =>
                const Center(child: CircularProgressIndicator()),
              ConfiguracionAgendaError(:final message) => _ConfiguracionError(
                message: message,
                onRetry: () => context.read<ConfiguracionAgendaBloc>().add(
                  const ConfiguracionAgendaCargada(),
                ),
              ),
              ConfiguracionAgendaLoaded() => _contenido(context, state),
            },
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, ConfiguracionAgendaLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Parámetros del local'),
          const Text(
            'Estos valores definen los bloques horarios que se ofrecen en la reserva.',
            style: AppTextStyles.muted,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _aperturaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hora de apertura (HH:MM)',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: _validarHora,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cierreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hora de cierre (HH:MM)',
                        prefixIcon: Icon(Icons.more_time),
                      ),
                      validator: _validarHora,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _intervaloCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duración por bloque (minutos)',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      validator: _validarDuracion,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: state.guardando
                          ? null
                          : () => _guardarConfiguracion(context),
                      icon: state.guardando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.blanco,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('GUARDAR CAMBIOS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfiguracionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ConfiguracionError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 46, color: AppColors.rojo),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grisTexto),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('REINTENTAR')),
          ],
        ),
      ),
    );
  }
}
