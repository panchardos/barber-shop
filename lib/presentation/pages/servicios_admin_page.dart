import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/servicio.dart';
import '../../injection_container.dart';
import '../blocs/servicios_admin/servicios_admin_bloc.dart';
import '../blocs/servicios_admin/servicios_admin_event.dart';
import '../blocs/servicios_admin/servicios_admin_state.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class ServiciosAdminPage extends StatelessWidget {
  const ServiciosAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ServiciosAdminBloc>()..add(const ServiciosAdminCargados()),
      child: const _ServiciosAdminView(),
    );
  }
}

class _ServiciosAdminView extends StatefulWidget {
  const _ServiciosAdminView();

  @override
  State<_ServiciosAdminView> createState() => _ServiciosAdminViewState();
}

class _ServiciosAdminViewState extends State<_ServiciosAdminView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _duracionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  double? _parsePrecio(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }

  void _crearServicio(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<ServiciosAdminBloc>().add(
      ServicioCreado(
        nombre: _nombreCtrl.text.trim(),
        duracionMinutos: int.parse(_duracionCtrl.text.trim()),
        precio: _parsePrecio(_precioCtrl.text)!,
      ),
    );

    _nombreCtrl.clear();
    _duracionCtrl.clear();
    _precioCtrl.clear();
  }

  Future<void> _editarPrecio(BuildContext context, Servicio servicio) async {
    var precioTexto = servicio.precio.toStringAsFixed(0);
    final precioFormKey = GlobalKey<FormState>();

    final nuevoPrecio = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Precio de ${servicio.nombre}'),
        content: Form(
          key: precioFormKey,
          child: TextFormField(
            initialValue: precioTexto,
            onChanged: (value) => precioTexto = value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Nuevo precio'),
            validator: (value) {
              final precio = _parsePrecio(value ?? '');
              if (precio == null || precio <= 0) {
                return 'Ingresá un precio mayor a cero';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () {
              if (precioFormKey.currentState!.validate()) {
                Navigator.pop(dialogContext, _parsePrecio(precioTexto));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nuevoPrecio == null || !context.mounted) return;
    context.read<ServiciosAdminBloc>().add(
      PrecioServicioActualizado(servicioId: servicio.id, precio: nuevoPrecio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiciosAdminBloc, ServiciosAdminState>(
      listenWhen: (previous, current) =>
          current is ServiciosAdminLoaded &&
          (current.errorMessage != null || current.successMessage != null),
      listener: (context, state) {
        if (state is! ServiciosAdminLoaded) return;
        final mensaje = state.errorMessage ?? state.successMessage;
        if (mensaje == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        context.read<ServiciosAdminBloc>().add(
          const ServiciosAdminMensajeLimpiado(),
        );
      },
      child: BlocBuilder<ServiciosAdminBloc, ServiciosAdminState>(
        builder: (context, state) {
          return AdminScaffold(
            selected: AdminSection.servicios,
            body: switch (state) {
              ServiciosAdminInitial() || ServiciosAdminLoading() =>
                const Center(child: CircularProgressIndicator()),
              ServiciosAdminError(:final message) => _ServiciosError(
                message: message,
                onRetry: () => context.read<ServiciosAdminBloc>().add(
                  const ServiciosAdminCargados(),
                ),
              ),
              ServiciosAdminLoaded() => _contenido(context, state),
            },
          );
        },
      ),
    );
  }

  Widget _contenido(BuildContext context, ServiciosAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Servicios ofrecidos'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Registrar nuevo servicio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del servicio',
                        hintText: 'Ej: Coloración',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresá el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _duracionCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duración (min)',
                            ),
                            validator: (value) {
                              final duracion = int.tryParse(
                                value?.trim() ?? '',
                              );
                              if (duracion == null || duracion <= 0) {
                                return 'Duración inválida';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _precioCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Precio (\$)',
                            ),
                            validator: (value) {
                              final precio = _parsePrecio(value ?? '');
                              if (precio == null || precio <= 0) {
                                return 'Precio inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: state.guardando
                          ? null
                          : () => _crearServicio(context),
                      child: state.guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.blanco,
                              ),
                            )
                          : const Text('GUARDAR SERVICIO'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Lista de precios actuales'),
          if (state.servicios.isEmpty)
            const Text('No hay servicios cargados.', style: AppTextStyles.muted)
          else
            ...state.servicios.map(
              (servicio) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ServicioItem(
                  servicio: servicio,
                  onEdit: () => _editarPrecio(context, servicio),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServicioItem extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onEdit;

  const _ServicioItem({required this.servicio, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(servicio.nombre, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    '${servicio.duracionMinutos} min',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
            Text(
              '\$${servicio.precio.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Editar precio',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiciosError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ServiciosError({required this.message, required this.onRetry});

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
