import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/turno.dart';
import '../../injection_container.dart';
import '../blocs/historial_cliente/historial_cliente_bloc.dart';
import '../blocs/historial_cliente/historial_cliente_event.dart';
import '../blocs/historial_cliente/historial_cliente_state.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class HistorialClientePage extends StatelessWidget {
  const HistorialClientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HistorialClienteBloc>(),
      child: const _HistorialClienteView(),
    );
  }
}

class _HistorialClienteView extends StatefulWidget {
  const _HistorialClienteView();

  @override
  State<_HistorialClienteView> createState() => _HistorialClienteViewState();
}

class _HistorialClienteViewState extends State<_HistorialClienteView> {
  final _telefonoCtrl = TextEditingController();

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _buscar(BuildContext context) {
    context.read<HistorialClienteBloc>().add(
      HistorialClienteBuscado(_telefonoCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialClienteBloc, HistorialClienteState>(
      listenWhen: (previous, current) => current is HistorialClienteError,
      listener: (context, state) {
        if (state is HistorialClienteError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<HistorialClienteBloc, HistorialClienteState>(
        builder: (context, state) {
          return AdminScaffold(
            selected: AdminSection.historial,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionTitle('Historial de cliente'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _buscar(context),
                          decoration: const InputDecoration(
                            labelText: 'Teléfono del cliente',
                            hintText: 'Ej: 2611234567',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.search),
                        onPressed: () => _buscar(context),
                        tooltip: 'Buscar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: switch (state) {
                      HistorialClienteInitial() => const _EstadoHistorial(
                        icon: Icons.manage_search,
                        mensaje:
                            'Ingresá un teléfono para consultar el historial.',
                      ),
                      HistorialClienteLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      HistorialClienteLoaded(:final turnos) =>
                        turnos.isEmpty
                            ? const _EstadoHistorial(
                                icon: Icons.person_off_outlined,
                                mensaje:
                                    'No se encontraron turnos para este cliente.',
                              )
                            : _ListaHistorial(turnos: turnos),
                      HistorialClienteError(:final message) => _EstadoHistorial(
                        icon: Icons.error_outline,
                        mensaje: message,
                      ),
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListaHistorial extends StatelessWidget {
  final List<Turno> turnos;

  const _ListaHistorial({required this.turnos});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: turnos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final turno = turnos[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.grisFondo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_note_outlined,
                    color: AppColors.negro,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        turno.servicio.nombre,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${turno.fechaYMD} | Hora: ${turno.hora}',
                        style: AppTextStyles.muted,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    turno.cliente.nombre,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EstadoHistorial extends StatelessWidget {
  final IconData icon;
  final String mensaje;

  const _EstadoHistorial({required this.icon, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.grisTexto),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.muted,
          ),
        ],
      ),
    );
  }
}
