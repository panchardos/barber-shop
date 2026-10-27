import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../application/use_cases/configurar_agenda.dart';

class ConfiguracionAgendaScreen extends StatefulWidget {
  const ConfiguracionAgendaScreen({super.key});

  @override
  State<ConfiguracionAgendaScreen> createState() =>
      _ConfiguracionAgendaScreenState();
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
          _aperturaCtrl.text = configActual.apertura;
          _cierreCtrl.text = configActual.cierre;
          _intervaloCtrl.text = configActual.duracionBloqueMinutos.toString();
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

  String? _validarHora(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ingrese una hora";
    }
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(value.trim())) {
      return "Use el formato HH:MM";
    }
    return null;
  }

  String? _validarDuracion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Ingrese el intervalo";
    }
    final numero = int.tryParse(value.trim());
    if (numero == null || numero <= 0) {
      return "Debe ser un número mayor a 0";
    }
    return null;
  }

  int? _horaAMinutos(String hora) {
    final partes = hora.split(':');
    if (partes.length != 2) return null;
    final horas = int.tryParse(partes[0]);
    final minutos = int.tryParse(partes[1]);
    if (horas == null || minutos == null) return null;
    return (horas * 60) + minutos;
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    final apertura = _aperturaCtrl.text.trim();
    final cierre = _cierreCtrl.text.trim();
    final aperturaMinutos = _horaAMinutos(apertura);
    final cierreMinutos = _horaAMinutos(cierre);

    if (aperturaMinutos == null ||
        cierreMinutos == null ||
        aperturaMinutos >= cierreMinutos) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La hora de apertura debe ser anterior a la de cierre"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final useCase = getIt<ConfigurarAgendaUseCase>();
      await useCase.guardarHorario(
        apertura: apertura,
        cierre: cierre,
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
      appBar: AppBar(title: const Text("Configuración de Agenda (HU 7)")),
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
                validator: _validarHora,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cierreCtrl,
                decoration: const InputDecoration(
                  labelText: "Hora de Cierre (HH:MM)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.more_time),
                ),
                validator: _validarHora,
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
                validator: _validarDuracion,
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
