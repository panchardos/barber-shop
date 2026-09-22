import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../domain/entities/turno.dart';
import '../../domain/entities/servicio.dart';
import '../../application/use_cases/obtener_turnos_por_dia.dart';
import '../../application/use_cases/cancelar_turno.dart';
import '../../application/use_cases/obtener_catalogo_servicios.dart';
import '../../application/use_cases/agendar_turno.dart';
import 'historial_cliente_screen.dart';
import 'configuracion_agenda_screen.dart';

class AgendaMainScreen extends StatefulWidget {
  const AgendaMainScreen({super.key});

  @override
  State<AgendaMainScreen> createState() => _AgendaMainScreenState();
}

class _AgendaMainScreenState extends State<AgendaMainScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Turno> _turnosDelDia = [];

  @override
  void initState() {
    super.initState();
    _cargarTurnos();
  }

  String get _fechaYMDFormatted {
    return "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  void _cargarTurnos() {
    final useCase = getIt<ObtenerTurnosPorDiaUseCase>();
    setState(() {
      _turnosDelDia = useCase.execute(_fechaYMDFormatted);
    });
  }

  void _cancelarTurno(String id) {
    try {
      final useCase = getIt<CancelarTurnoUseCase>();
      useCase.execute(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Turno cancelado exitosamente")),
      );
      _cargarTurnos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Nota Barber Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Cliente (HU 8)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialClienteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración (HU 7)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfiguracionAgendaScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de Fecha
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Agenda: $_fechaYMDFormatted",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Cambiar fecha"),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                      _cargarTurnos();
                    }
                  },
                ),
              ],
            ),
          ),
          // Lista de Turnos
          Expanded(
            child: _turnosDelDia.isEmpty
                ? const Center(
                    child: Text(
                      "No hay turnos registrados para esta fecha.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _turnosDelDia.length,
                    itemBuilder: (context, index) {
                      final turno = _turnosDelDia[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(turno.hora),
                          ),
                          title: Text("${turno.cliente.nombre} (${turno.servicio.nombre})"),
                          subtitle: Text("Tel: ${turno.cliente.telefono} - \$${turno.servicio.precio}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarCancelacion(turno.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Nuevo Turno"),
        onPressed: () => _mostrarDialogoNuevoTurno(context),
      ),
    );
  }

  void _confirmarCancelacion(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Turno"),
        content: const Text("¿Estás seguro de que deseas cancelar esta reserva?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelarTurno(id);
            },
            child: const Text("Sí, cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevoTurno(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final horaCtrl = TextEditingController(text: "16:00");

    final catalogo = getIt<ObtenerCatalogoServiciosUseCase>().execute();
    Servicio? servicioSeleccionado = catalogo.isNotEmpty ? catalogo.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Agendar Nuevo Turno",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: "Nombre del Cliente"),
                ),
                TextField(
                  controller: telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                ),
                TextField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(labelText: "Hora (HH:MM)"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Servicio>(
                  initialValue: servicioSeleccionado,
                  items: catalogo
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text("${s.nombre} (\$${s.precio.toStringAsFixed(0)})"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setModalState(() {
                      servicioSeleccionado = val;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Servicio"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isEmpty ||
                        telefonoCtrl.text.isEmpty ||
                        servicioSeleccionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Complete todos los campos")),
                      );
                      return;
                    }

                    try {
                      final agendarUseCase = getIt<AgendarTurnoUseCase>();
                      agendarUseCase.execute(
                        nombreCliente: nombreCtrl.text.trim(),
                        telefonoCliente: telefonoCtrl.text.trim(),
                        servicioSeleccionado: servicioSeleccionado!,
                        fechaYMD: _fechaYMDFormatted,
                        hora: horaCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      _cargarTurnos();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Turno agendado exitosamente")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Confirmar Reserva"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}