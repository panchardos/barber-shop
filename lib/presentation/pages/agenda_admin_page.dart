import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/turno.dart';
import '../../injection_container.dart';
import '../blocs/agenda_admin/agenda_admin_bloc.dart';
import '../blocs/agenda_admin/agenda_admin_event.dart';
import '../blocs/agenda_admin/agenda_admin_state.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/cancelar_turno_dialog.dart';
import '../widgets/date_bubble.dart';
import '../widgets/nuevo_turno_sheet.dart';
import '../widgets/section_title.dart';
import '../widgets/turno_card.dart';

class AgendaAdminPage extends StatelessWidget {
  const AgendaAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AgendaAdminBloc>()
            ..add(AgendaAdminCargada(fecha: DateTime.now())),
      child: const _AgendaAdminView(),
    );
  }
}

class _AgendaAdminView extends StatelessWidget {
  const _AgendaAdminView();

  Future<void> _abrirCalendario(
    BuildContext context,
    DateTime fechaActual,
  ) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaActual,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (fecha != null && context.mounted) {
      context.read<AgendaAdminBloc>().add(AgendaAdminFechaSeleccionada(fecha));
    }
  }

  Future<void> _abrirNuevoTurno(BuildContext context, DateTime fecha) async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.blanco,
      builder: (_) => NuevoTurnoSheet(fecha: fecha),
    );

    if (creado == true && context.mounted) {
      context.read<AgendaAdminBloc>().add(const AgendaAdminRefrescada());
    }
  }

  Future<void> _cancelarTurno(BuildContext context, Turno turno) async {
    final confirmado = await mostrarDialogoCancelarTurno(context, turno);
    if (confirmado && context.mounted) {
      context.read<AgendaAdminBloc>().add(AgendaAdminTurnoCancelado(turno));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgendaAdminBloc, AgendaAdminState>(
      listenWhen: (previous, current) =>
          current is AgendaAdminLoaded &&
          (current.errorMessage != null || current.successMessage != null),
      listener: (context, state) {
        if (state is! AgendaAdminLoaded) return;
        final mensaje = state.errorMessage ?? state.successMessage;
        if (mensaje == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        context.read<AgendaAdminBloc>().add(const AgendaAdminMensajeLimpiado());
      },
      child: BlocBuilder<AgendaAdminBloc, AgendaAdminState>(
        builder: (context, state) {
          final loaded = state is AgendaAdminLoaded ? state : null;

          return AdminScaffold(
            selected: AdminSection.agenda,
            body: switch (state) {
              AgendaAdminInitial() || AgendaAdminLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AgendaAdminError(:final message) => _AgendaError(
                message: message,
                onRetry: () => context.read<AgendaAdminBloc>().add(
                  AgendaAdminCargada(fecha: DateTime.now()),
                ),
              ),
              AgendaAdminLoaded() => _contenido(context, state),
            },
            floatingActionButton: loaded == null
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _abrirNuevoTurno(context, loaded.fecha),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo turno'),
                  ),
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, AgendaAdminLoaded state) {
    final fechas = _fechasVisibles(state.fecha);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            'Agenda de turnos',
            trailing: IconButton(
              tooltip: 'Elegir fecha',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _abrirCalendario(context, state.fecha),
            ),
          ),
          if (state.cargando)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fechas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final fecha = fechas[index];
                return DateBubble(
                  fecha: fecha,
                  selected: fechaYMD(fecha) == fechaYMD(state.fecha),
                  onTap: () => context.read<AgendaAdminBloc>().add(
                    AgendaAdminFechaSeleccionada(fecha),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.turnos.isEmpty
                ? state.cargando
                      ? const Center(child: CircularProgressIndicator())
                      : const _AgendaVacia()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: state.turnos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final turno = state.turnos[index];
                      return TurnoCard(
                        turno: turno,
                        onCancel: state.cancelando
                            ? () {}
                            : () => _cancelarTurno(context, turno),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _fechasVisibles(DateTime fechaSeleccionada) {
    final inicio = fechaSeleccionada.subtract(const Duration(days: 3));
    return List.generate(7, (index) => inicio.add(Duration(days: index)));
  }
}

class _AgendaVacia extends StatelessWidget {
  const _AgendaVacia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 44,
            color: AppColors.grisTexto,
          ),
          SizedBox(height: 12),
          Text('No hay turnos para esta fecha.', style: AppTextStyles.muted),
        ],
      ),
    );
  }
}

class _AgendaError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AgendaError({required this.message, required this.onRetry});

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
