import 'package:flutter/material.dart';

import '../../application/use_cases/obtener_historial_cliente.dart';
import '../../domain/entities/turno.dart';
import '../../injection_container.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

class HistorialClienteScreen extends StatefulWidget {
  const HistorialClienteScreen({super.key});

  @override
  State<HistorialClienteScreen> createState() => _HistorialClienteScreenState();
}

class _HistorialClienteScreenState extends State<HistorialClienteScreen> {
  final _telefonoCtrl = TextEditingController();
  List<Turno> _historial = [];
  bool _busquedaRealizada = false;

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _buscarHistorial() {
    final telefono = _telefonoCtrl.text.trim();
    if (telefono.isEmpty) return;

    try {
      final useCase = getIt<ObtenerHistorialClienteUseCase>();
      final resultado = useCase.execute(telefono);

      setState(() {
        _historial = resultado;
        _busquedaRealizada = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al consultar el historial: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    onSubmitted: (_) => _buscarHistorial(),
                    decoration: const InputDecoration(
                      labelText: "Teléfono del cliente",
                      hintText: "Ej: 2611234567",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarHistorial,
                  tooltip: "Buscar",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !_busquedaRealizada
                  ? const _EstadoHistorial(
                      icon: Icons.manage_search,
                      mensaje:
                          "Ingresá un teléfono para consultar el historial.",
                    )
                  : _historial.isEmpty
                  ? const _EstadoHistorial(
                      icon: Icons.person_off_outlined,
                      mensaje: "No se encontraron turnos para este cliente.",
                    )
                  : ListView.separated(
                      itemCount: _historial.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final turno = _historial[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        turno.servicio.nombre,
                                        style: AppTextStyles.cardTitle,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Fecha: ${turno.fechaYMD} | Hora: ${turno.hora}",
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
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
