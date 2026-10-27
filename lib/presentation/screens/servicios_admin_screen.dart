import 'package:flutter/material.dart';

import '../../application/use_cases/actualizar_precio_servicio.dart';
import '../../application/use_cases/crear_servicio.dart';
import '../../application/use_cases/obtener_catalogo_servicios.dart';
import '../../domain/entities/servicio.dart';
import '../../injection_container.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class ServiciosAdminScreen extends StatefulWidget {
  const ServiciosAdminScreen({super.key});

  @override
  State<ServiciosAdminScreen> createState() => _ServiciosAdminScreenState();
}

class _ServiciosAdminScreenState extends State<ServiciosAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();

  List<Servicio> _servicios = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _duracionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _cargarServicios() {
    setState(() {
      _servicios = getIt<ObtenerCatalogoServiciosUseCase>().execute();
    });
  }

  double? _parsePrecio(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.'));
  }

  Future<void> _crearServicio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await getIt<CrearServicioUseCase>().execute(
        nombre: _nombreCtrl.text,
        duracionMinutos: int.parse(_duracionCtrl.text.trim()),
        precio: _parsePrecio(_precioCtrl.text)!,
      );

      if (!mounted) return;
      _nombreCtrl.clear();
      _duracionCtrl.clear();
      _precioCtrl.clear();
      _cargarServicios();
      _mostrarMensaje('Servicio creado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo crear el servicio: $e');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _editarPrecio(Servicio servicio) async {
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

    if (nuevoPrecio == null) return;

    try {
      await getIt<ActualizarPrecioServicioUseCase>().execute(
        servicio.id,
        nuevoPrecio,
      );
      if (!mounted) return;
      _cargarServicios();
      _mostrarMensaje('Precio actualizado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo actualizar el precio: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selected: AdminSection.servicios,
      body: SingleChildScrollView(
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                        onPressed: _guardando ? null : _crearServicio,
                        child: _guardando
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
            if (_servicios.isEmpty)
              const Text(
                'No hay servicios cargados.',
                style: AppTextStyles.muted,
              )
            else
              ..._servicios.map(
                (servicio) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ServicioItem(
                    servicio: servicio,
                    onEdit: () => _editarPrecio(servicio),
                  ),
                ),
              ),
          ],
        ),
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
