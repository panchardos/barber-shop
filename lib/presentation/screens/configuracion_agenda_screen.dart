import 'package:flutter/material.dart';

import '../../application/use_cases/configurar_agenda.dart';
import '../../injection_container.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/section_title.dart';

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

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracionActual();
  }

  @override
  void dispose() {
    _aperturaCtrl.dispose();
    _cierreCtrl.dispose();
    _intervaloCtrl.dispose();
    super.dispose();
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
          backgroundColor: AppColors.rojo,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final useCase = getIt<ConfigurarAgendaUseCase>();
      await useCase.guardarHorario(
        apertura: apertura,
        cierre: cierre,
        duracionBloque: int.parse(_intervaloCtrl.text.trim()),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuración guardada correctamente")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: AppColors.rojo,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selected: AdminSection.configuracion,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle('Parámetros del local'),
            const Text(
              'Estos valores definen los bloques horarios que se ofrecen en la reserva.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _aperturaCtrl,
                        decoration: const InputDecoration(
                          labelText: "Hora de apertura (HH:MM)",
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: _validarHora,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cierreCtrl,
                        decoration: const InputDecoration(
                          labelText: "Hora de cierre (HH:MM)",
                          prefixIcon: Icon(Icons.more_time),
                        ),
                        validator: _validarHora,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _intervaloCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Duración por bloque (minutos)",
                          prefixIcon: Icon(Icons.timer),
                        ),
                        validator: _validarDuracion,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardarConfiguracion,
                        icon: _guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.blanco,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text("GUARDAR CAMBIOS"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
