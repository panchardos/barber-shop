import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bloqueo.dart';
import '../../injection_container.dart';
import '../blocs/bloqueos_admin/bloqueos_admin_bloc.dart';
import '../blocs/bloqueos_admin/bloqueos_admin_event.dart';
import '../blocs/bloqueos_admin/bloqueos_admin_state.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class BloqueosAdminPage extends StatelessWidget {
  const BloqueosAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BloqueosAdminBloc>()
            ..add(BloqueosAdminCargados(DateTime.now())),
      child: const _BloqueosAdminView(),
    );
  }
}

class _BloqueosAdminView extends StatelessWidget {
  const _BloqueosAdminView();

  Future<void> _elegirFecha(BuildContext context, DateTime actual) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (fecha != null && context.mounted) {
      context.read<BloqueosAdminBloc>().add(BloqueosAdminCargados(fecha));
    }
  }

  Future<void> _nuevoBloqueo(BuildContext context, DateTime fecha) async {
    final data = await showModalBottomSheet<_BloqueoFormData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.blanco,
      builder: (_) => _NuevoBloqueoSheet(fecha: fecha),
    );
    if (data != null && context.mounted) {
      context.read<BloqueosAdminBloc>().add(
        BloqueoAgregado(
          fecha: fecha,
          todoElDia: data.todoElDia,
          horaInicio: data.horaInicio,
          horaFin: data.horaFin,
          motivo: data.motivo,
        ),
      );
    }
  }

  Future<void> _eliminar(BuildContext context, Bloqueo bloqueo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar bloqueo'),
        content: Text(
          '¿Querés eliminar el bloqueo del ${bloqueo.fechaYMD}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true && context.mounted) {
      context.read<BloqueosAdminBloc>().add(BloqueoEliminado(bloqueo.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BloqueosAdminBloc, BloqueosAdminState>(
      listenWhen: (previous, current) =>
          current is BloqueosAdminLoaded &&
          (current.errorMessage != null || current.successMessage != null),
      listener: (context, state) {
        if (state is! BloqueosAdminLoaded) return;
        final mensaje = state.errorMessage ?? state.successMessage;
        if (mensaje == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        context.read<BloqueosAdminBloc>().add(
          const BloqueosAdminMensajeLimpiado(),
        );
      },
      child: BlocBuilder<BloqueosAdminBloc, BloqueosAdminState>(
        builder: (context, state) {
          final loaded = state is BloqueosAdminLoaded ? state : null;
          return AdminScaffold(
            selected: AdminSection.bloqueos,
            body: switch (state) {
              BloqueosAdminInitial() || BloqueosAdminLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              BloqueosAdminError(:final message) => _BloqueosError(
                message: message,
                onRetry: () => context.read<BloqueosAdminBloc>().add(
                  BloqueosAdminCargados(DateTime.now()),
                ),
              ),
              BloqueosAdminLoaded() => _contenido(context, state),
            },
            floatingActionButton: loaded == null
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _nuevoBloqueo(context, loaded.fecha),
                    icon: const Icon(Icons.block),
                    label: const Text('Nuevo bloqueo'),
                  ),
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, BloqueosAdminLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            'Bloqueos excepcionales',
            trailing: IconButton(
              tooltip: 'Elegir fecha',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _elegirFecha(context, state.fecha),
            ),
          ),
          Text(fechaLarga(state.fecha), style: AppTextStyles.muted),
          const SizedBox(height: 12),
          if (state.guardando || state.eliminando)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Expanded(
            child: state.bloqueos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay bloqueos para esta fecha.',
                      style: AppTextStyles.muted,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: state.bloqueos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final bloqueo = state.bloqueos[index];
                      return _BloqueoCard(
                        bloqueo: bloqueo,
                        onDelete: state.eliminando
                            ? null
                            : () => _eliminar(context, bloqueo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BloqueoCard extends StatelessWidget {
  final Bloqueo bloqueo;
  final VoidCallback? onDelete;

  const _BloqueoCard({required this.bloqueo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final rango = bloqueo.todoElDia
        ? 'Todo el día'
        : '${bloqueo.horaInicio ?? ''} a ${bloqueo.horaFin ?? ''}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.grisFondo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.block, color: AppColors.negro),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rango, style: AppTextStyles.cardTitle),
                  if (bloqueo.motivo != null && bloqueo.motivo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(bloqueo.motivo!, style: AppTextStyles.muted),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Eliminar bloqueo',
              icon: const Icon(Icons.delete_outline, color: AppColors.rojo),
            ),
          ],
        ),
      ),
    );
  }
}

class _NuevoBloqueoSheet extends StatefulWidget {
  final DateTime fecha;

  const _NuevoBloqueoSheet({required this.fecha});

  @override
  State<_NuevoBloqueoSheet> createState() => _NuevoBloqueoSheetState();
}

class _NuevoBloqueoSheetState extends State<_NuevoBloqueoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _inicioCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  bool _todoElDia = false;

  @override
  void dispose() {
    _inicioCtrl.dispose();
    _finCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  String? _validarHora(String? value) {
    final hora = value?.trim() ?? '';
    if (hora.isEmpty) return 'Ingresá una hora';
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(hora)) {
      return 'Usá el formato HH:MM';
    }
    return null;
  }

  void _guardar() {
    if (!_todoElDia && !_formKey.currentState!.validate()) return;

    final inicio = _inicioCtrl.text.trim();
    final fin = _finCtrl.text.trim();
    if (!_todoElDia && inicio.compareTo(fin) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El bloqueo debe comenzar antes de terminar'),
          backgroundColor: AppColors.rojo,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _BloqueoFormData(
        todoElDia: _todoElDia,
        horaInicio: _todoElDia ? null : inicio,
        horaFin: _todoElDia ? null : fin,
        motivo: _motivoCtrl.text.trim().isEmpty
            ? null
            : _motivoCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bloquear ${fechaLarga(widget.fecha)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                key: const Key('bloqueo-todo-el-dia'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Todo el día'),
                value: _todoElDia,
                onChanged: (value) => setState(() => _todoElDia = value),
              ),
              if (!_todoElDia) ...[
                TextFormField(
                  controller: _inicioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hora de inicio (HH:MM)',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: _validarHora,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _finCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hora de fin (HH:MM)',
                    prefixIcon: Icon(Icons.more_time),
                  ),
                  validator: _validarHora,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _motivoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motivo (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('GUARDAR BLOQUEO'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloqueoFormData {
  final bool todoElDia;
  final String? horaInicio;
  final String? horaFin;
  final String? motivo;

  const _BloqueoFormData({
    required this.todoElDia,
    this.horaInicio,
    this.horaFin,
    this.motivo,
  });
}

class _BloqueosError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BloqueosError({required this.message, required this.onRetry});

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
