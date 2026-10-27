import 'package:flutter/material.dart';

import '../../application/use_cases/agendar_turno.dart';
import '../../application/use_cases/obtener_catalogo_servicios.dart';
import '../../application/use_cases/obtener_horarios_disponibles.dart';
import '../../domain/entities/servicio.dart';
import '../../injection_container.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import 'section_title.dart';
import 'time_slot_grid.dart';

class NuevoTurnoSheet extends StatefulWidget {
  final DateTime fecha;
  final String fechaYMD;

  const NuevoTurnoSheet({
    super.key,
    required this.fecha,
    required this.fechaYMD,
  });

  @override
  State<NuevoTurnoSheet> createState() => _NuevoTurnoSheetState();
}

class _NuevoTurnoSheetState extends State<NuevoTurnoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  List<String> _horarios = [];
  String? _horaSeleccionada;
  bool _cargandoHorarios = false;
  bool _guardando = false;
  String? _errorHorarios;
  int _solicitud = 0;

  @override
  void initState() {
    super.initState();
    _servicios = getIt<ObtenerCatalogoServiciosUseCase>().execute();
    _servicioSeleccionado = _servicios.isNotEmpty ? _servicios.first : null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarHorarios());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHorarios() async {
    final servicio = _servicioSeleccionado;
    if (servicio == null) {
      setState(() {
        _horarios = [];
        _horaSeleccionada = null;
        _cargandoHorarios = false;
      });
      return;
    }

    final solicitud = ++_solicitud;
    setState(() {
      _cargandoHorarios = true;
      _errorHorarios = null;
      _horaSeleccionada = null;
    });

    try {
      final horarios = await getIt<ObtenerHorariosDisponiblesUseCase>().execute(
        fechaYMD: widget.fechaYMD,
        servicio: servicio,
      );

      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _horarios = horarios;
        _cargandoHorarios = false;
      });
    } catch (e) {
      if (!mounted || solicitud != _solicitud) return;
      setState(() {
        _horarios = [];
        _errorHorarios = e.toString();
        _cargandoHorarios = false;
      });
    }
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_servicioSeleccionado == null) {
      _mostrarMensaje('Seleccioná un servicio.');
      return;
    }
    if (_horaSeleccionada == null) {
      _mostrarMensaje('Seleccioná un horario disponible.');
      return;
    }

    setState(() => _guardando = true);

    try {
      await getIt<AgendarTurnoUseCase>().execute(
        nombreCliente: _nombreCtrl.text.trim(),
        telefonoCliente: _telefonoCtrl.text.trim(),
        servicioSeleccionado: _servicioSeleccionado!,
        fechaYMD: widget.fechaYMD,
        hora: _horaSeleccionada!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _errorHorarios = null;
      });
      _mostrarMensaje('Error: $e');
      _cargarHorarios();
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grisBorde,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Agendar nuevo turno',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(fechaLarga(widget.fecha), style: AppTextStyles.muted),
                  const SizedBox(height: 24),
                  const SectionTitle('Servicio'),
                  DropdownButtonFormField<Servicio>(
                    initialValue: _servicioSeleccionado,
                    items: _servicios
                        .map(
                          (servicio) => DropdownMenuItem(
                            value: servicio,
                            child: Text(
                              '${servicio.nombre} (${servicio.duracionMinutos} min)',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) {
                      setState(() => _servicioSeleccionado = valor);
                      _cargarHorarios();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Elegí un servicio',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle('Horario disponible'),
                  TimeSlotGrid(
                    horarios: _horarios,
                    seleccionado: _horaSeleccionada,
                    onSelected: (hora) {
                      setState(() => _horaSeleccionada = hora);
                    },
                    cargando: _cargandoHorarios,
                    error: _errorHorarios,
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle('Datos del cliente'),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre y apellido',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresá el nombre del cliente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (value) {
                      final telefono = value?.trim() ?? '';
                      if (telefono.isEmpty) {
                        return 'Ingresá el teléfono';
                      }
                      if (!RegExp(r'^[0-9]{6,}$').hasMatch(telefono)) {
                        return 'Ingresá un teléfono numérico';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardando ? null : _confirmar,
                    child: _guardando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.blanco,
                            ),
                          )
                        : const Text('CONFIRMAR RESERVA'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _guardando
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
