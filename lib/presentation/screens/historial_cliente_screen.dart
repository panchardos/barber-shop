import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../domain/entities/turno.dart';
import '../../application/use_cases/obtener_historial_cliente.dart';

class HistorialClienteScreen extends StatefulWidget {
  const HistorialClienteScreen({super.key});

  @override
  State<HistorialClienteScreen> createState() => _HistorialClienteScreenState();
}

class _HistorialClienteScreenState extends State<HistorialClienteScreen> {
  final _telefonoCtrl = TextEditingController();
  List<Turno> _historial = [];
  bool _busquedaRealizada = false;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Cliente (HU 8)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de Búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Teléfono del cliente",
                      hintText: "Ej: 2611234567",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
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
            // Resultados
            Expanded(
              child: !_busquedaRealizada
                  ? const Center(
                      child: Text(
                        "Ingrese un número de teléfono para consultar el historial.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _historial.isEmpty
                      ? const Center(
                          child: Text(
                            "No se encontraron turnos registrados para este cliente.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _historial.length,
                          itemBuilder: (context, index) {
                            final turno = _historial[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.event_note, color: Colors.blue),
                                ),
                                title: Text("${turno.servicio.nombre} - \$${turno.servicio.precio}"),
                                subtitle: Text("Fecha: ${turno.fechaYMD} | Hora: ${turno.hora}"),
                                trailing: Text(
                                  turno.cliente.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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