import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../application/use_cases/configurar_agenda.dart';

class ConfiguracionAgendaScreen extends StatefulWidget {
  const ConfiguracionAgendaScreen({super.key});

  @override
  State<ConfiguracionAgendaScreen> createState() => _ConfiguracionAgendaScreenState();
}

class _ConfiguracionAgendaScreenState extends State<ConfiguracionAgendaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _aperturaCtrl = TextEditingController();
  final _cierreCtrl = TextEditingController();
  final _intervaloCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarConfiguracionActual();
  }

  Future<void> _cargarConfiguracionActual() async {
    try {
      final useCase = getIt<ConfigurarAgendaUseCase>();
      final configActual = await useCase.obtenerHorario();
      
      if (mounted) {
        setState(() {
          _aperturaCtrl.text = configActual['apertura']?.toString() ?? "09:00";
          _cierreCtrl.text = configActual['cierre']?.toString() ?? "20:00";
          _intervaloCtrl.text = configActual['duracionBloqueMinutos']?.toString() ?? "30";
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _aperturaCtrl.text = "09:00";
          _cierreCtrl.text = "20:00";
          _intervaloCtrl.text = "30";
        });
      }
    }
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final useCase = getIt<ConfigurarAgendaUseCase>();
      await useCase.guardarHorario(
        apertura: _aperturaCtrl.text.trim(),
        cierre: _cierreCtrl.text.trim(),
        duracionBloque: int.parse(_intervaloCtrl.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Configuración guardada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de Agenda (HU 7)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Parámetros del Local",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aperturaCtrl,
                decoration: const InputDecoration(
                  labelText: "Hora de Apertura (HH:MM)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese la hora de apertura" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cierreCtrl,
                decoration: const InputDecoration(
                  labelText: "Hora de Cierre (HH:MM)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.more_time),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese la hora de cierre" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _intervaloCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duración por Bloque (Minutos)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Ingrese el intervalo";
                  if (int.tryParse(value) == null) return "Debe ser un número válido";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar Cambios"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardarConfiguracion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}