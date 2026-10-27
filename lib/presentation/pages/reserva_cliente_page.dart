import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../app_routes.dart';
import '../blocs/reserva/reserva_bloc.dart';
import '../blocs/reserva/reserva_event.dart';
import '../blocs/reserva/reserva_state.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/section_title.dart';
import '../widgets/service_select_card.dart';
import '../widgets/time_slot_grid.dart';

class ReservaClientePage extends StatelessWidget {
  const ReservaClientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReservaBloc>()..add(ReservaIniciada(soloFecha(DateTime.now()))),
      child: const _ReservaClienteView(),
    );
  }
}

class _ReservaClienteView extends StatefulWidget {
  const _ReservaClienteView();

  @override
  State<_ReservaClienteView> createState() => _ReservaClienteViewState();
}

class _ReservaClienteViewState extends State<_ReservaClienteView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _mostrarConfirmacion(
    BuildContext context,
    ReservaSuccess success,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.grisFondo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.negro, size: 30),
        ),
        title: const Text(
          'Turno confirmado',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.negro),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              success.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.negro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${success.servicio.nombre} · ${success.hora} hs',
              style: const TextStyle(color: AppColors.negro),
            ),
            const SizedBox(height: 4),
            Text(
              fechaLarga(success.fecha),
              style: const TextStyle(color: AppColors.grisTexto),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ACEPTAR'),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (!mounted) return;
    _nombreCtrl.clear();
    _telefonoCtrl.clear();
    context.read<ReservaBloc>().add(ReservaIniciada(soloFecha(DateTime.now())));
  }

  void _confirmarReserva(BuildContext context) {
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
    return Scaffold(
      body: SafeArea(
        child: BlocListener<ReservaBloc, ReservaState>(
          listenWhen: (previous, current) =>
              current is ReservaSuccess ||
              (current is ReservaLoaded && current.errorMessage != null),
          listener: (context, state) {
            if (state is ReservaSuccess) {
              _mostrarConfirmacion(context, state);
            } else if (state is ReservaLoaded && state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              context.read<ReservaBloc>().add(const ReservaMensajeLimpiado());
            }
          },
          child: BlocBuilder<ReservaBloc, ReservaState>(
            builder: (context, state) {
              return switch (state) {
                ReservaInitial() || ReservaLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ReservaError(:final message) => _ErrorReserva(
                  message: message,
                  onRetry: () => context.read<ReservaBloc>().add(
                    ReservaIniciada(soloFecha(DateTime.now())),
                  ),
                ),
                ReservaSuccess() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ReservaLoaded() => _contenido(context, state),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, ReservaLoaded state) {
    final hoy = soloFecha(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _encabezado(context),
              const SizedBox(height: 24),
              const SectionTitle('1. Elegí tu servicio'),
              if (state.servicios.isEmpty)
                const Text(
                  'No hay servicios disponibles por el momento.',
                  style: AppTextStyles.muted,
                )
              else
                ...state.servicios.map(
                  (servicio) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ServiceSelectCard(
                      servicio: servicio,
                      selected: state.servicioSeleccionado?.id == servicio.id,
                      onTap: () => context.read<ReservaBloc>().add(
                        ReservaServicioSeleccionado(servicio),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const SectionTitle('2. Fecha y horario'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grisBorde),
                ),
                child: SizedBox(
                  height: 330,
                  child: CalendarDatePicker(
                    key: ValueKey(state.fecha),
                    initialDate: state.fecha,
                    firstDate: hoy,
                    lastDate: hoy.add(const Duration(days: 90)),
                    onDateChanged: (fecha) {
                      context.read<ReservaBloc>().add(
                        ReservaFechaSeleccionada(fecha),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 8),
              const Text(
                'Los horarios se calculan según la configuración del local.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 24),
              const SectionTitle('3. Completá tus datos'),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de contacto',
                      ),
                      validator: (value) {
                        final telefono = value?.trim() ?? '';
                        if (telefono.isEmpty) {
                          return 'Ingresá tu teléfono';
                        }
                        if (!RegExp(r'^[0-9]{6,}$').hasMatch(telefono)) {
                          return 'Ingresá un teléfono numérico';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.enviando
                    ? null
                    : () => _confirmarReserva(context),
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
              const SizedBox(height: 20),
              const Text(
                'lanotabarbershop.com',
                textAlign: TextAlign.center,
                style: AppTextStyles.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            children: [
              Text(
                'LA NOTA BARBER SHOP',
                textAlign: TextAlign.center,
                style: AppTextStyles.brand.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Reservá tu turno',
                style: AppTextStyles.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Panel administrador',
          icon: const Icon(Icons.admin_panel_settings_outlined),
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.admin);
            if (!context.mounted || !mounted) return;
            context.read<ReservaBloc>().add(
              ReservaIniciada(soloFecha(DateTime.now())),
            );
          },
        ),
      ],
    );
  }
}

class _ErrorReserva extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorReserva({required this.message, required this.onRetry});

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
