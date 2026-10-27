import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/servicio.dart';
import '../../injection_container.dart';
import '../blocs/reserva/reserva_bloc.dart';
import '../blocs/reserva/reserva_event.dart';
import '../blocs/reserva/reserva_state.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import 'section_title.dart';
import 'time_slot_grid.dart';

class NuevoTurnoSheet extends StatelessWidget {
  final DateTime fecha;

  const NuevoTurnoSheet({super.key, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReservaBloc>()..add(ReservaIniciada(soloFecha(fecha))),
      child: const _NuevoTurnoView(),
    );
  }
}

class _NuevoTurnoView extends StatefulWidget {
  const _NuevoTurnoView();

  @override
  State<_NuevoTurnoView> createState() => _NuevoTurnoViewState();
}

class _NuevoTurnoViewState extends State<_NuevoTurnoView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _confirmar(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ReservaBloc>().add(
      ReservaConfirmada(
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<ReservaBloc, ReservaState>(
      listenWhen: (previous, current) =>
          current is ReservaSuccess ||
          (current is ReservaLoaded && current.errorMessage != null),
      listener: (context, state) {
        if (state is ReservaSuccess) {
          Navigator.pop(context, true);
        } else if (state is ReservaLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<ReservaBloc>().add(const ReservaMensajeLimpiado());
        }
      },
      child: BlocBuilder<ReservaBloc, ReservaState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: switch (state) {
              ReservaInitial() || ReservaLoading() => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              ReservaError(:final message) => _ErrorNuevoTurno(
                message: message,
                onRetry: () => context.read<ReservaBloc>().add(
                  ReservaIniciada(soloFecha(DateTime.now())),
                ),
              ),
              ReservaSuccess() => const SizedBox.shrink(),
              ReservaLoaded() => _contenido(context, state),
            },
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, ReservaLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grisBorde,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Agendar nuevo turno',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(fechaLarga(state.fecha), style: AppTextStyles.muted),
                const SizedBox(height: 24),
                const SectionTitle('Servicio'),
                DropdownButtonFormField<Servicio>(
                  initialValue: state.servicioSeleccionado,
                  items: state.servicios
                      .map(
                        (servicio) => DropdownMenuItem(
                          value: servicio,
                          child: Text(
                            '${servicio.nombre} (${servicio.duracionMinutos} min)',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor == null) return;
                    context.read<ReservaBloc>().add(
                      ReservaServicioSeleccionado(valor),
                    );
                  },
                  decoration: const InputDecoration(
                    hintText: 'Elegí un servicio',
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle('Horario disponible'),
                TimeSlotGrid(
                  horarios: state.horarios,
                  seleccionado: state.horaSeleccionada,
                  onSelected: (hora) {
                    context.read<ReservaBloc>().add(
                      ReservaHorarioSeleccionado(hora),
                    );
                  },
                  cargando: state.cargandoHorarios,
                  error: state.errorMessage,
                ),
                const SizedBox(height: 20),
                const SectionTitle('Datos del cliente'),
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre y apellido',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresá el nombre del cliente';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) {
                    final telefono = value?.trim() ?? '';
                    if (telefono.isEmpty) {
                      return 'Ingresá el teléfono';
                    }
                    if (!RegExp(r'^[0-9]{6,}$').hasMatch(telefono)) {
                      return 'Ingresá un teléfono numérico';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.enviando ? null : () => _confirmar(context),
                  child: state.enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blanco,
                          ),
                        )
                      : const Text('CONFIRMAR RESERVA'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.enviando
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorNuevoTurno extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorNuevoTurno({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 42, color: AppColors.rojo),
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
    );
  }
}
