import 'package:flutter/material.dart';

import '../../application/use_cases/agendar_turno.dart';
import '../../application/use_cases/obtener_catalogo_servicios.dart';
import '../../application/use_cases/obtener_horarios_disponibles.dart';
import '../../domain/entities/servicio.dart';
import '../../injection_container.dart';
import '../app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/section_title.dart';
import '../widgets/service_select_card.dart';
import '../widgets/time_slot_grid.dart';

class ReservaClienteScreen extends StatefulWidget {
  const ReservaClienteScreen({super.key});

  @override
  State<ReservaClienteScreen> createState() => _ReservaClienteScreenState();
}

class _ReservaClienteScreenState extends State<ReservaClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  late final DateTime _hoy;
  late DateTime _fechaSeleccionada;
  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  List<String> _horarios = [];
  String? _horaSeleccionada;
  bool _cargandoHorarios = false;
  bool _enviando = false;
  String? _errorHorarios;
  int _solicitud = 0;

  @override
  void initState() {
    super.initState();
    _hoy = soloFecha(DateTime.now());
    _fechaSeleccionada = _hoy;
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

  String get _fechaYMD => fechaYMD(_fechaSeleccionada);

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
        fechaYMD: _fechaYMD,
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

  void _seleccionarServicio(Servicio servicio) {
    if (_servicioSeleccionado?.id == servicio.id) return;
    setState(() => _servicioSeleccionado = servicio);
    _cargarHorarios();
  }

  void _seleccionarFecha(DateTime fecha) {
    final fechaNormalizada = soloFecha(fecha);
    if (fechaNormalizada == _fechaSeleccionada) return;
    setState(() => _fechaSeleccionada = fechaNormalizada);
    _cargarHorarios();
  }

  Future<void> _confirmarReserva() async {
    if (!_formKey.currentState!.validate()) return;
    if (_servicioSeleccionado == null) {
      _mostrarMensaje('Seleccioná un servicio.');
      return;
    }
    if (_horaSeleccionada == null) {
      _mostrarMensaje('Seleccioná un horario disponible.');
      return;
    }

    final servicio = _servicioSeleccionado!;
    final hora = _horaSeleccionada!;
    final nombre = _nombreCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    final fecha = _fechaSeleccionada;

    setState(() => _enviando = true);

    try {
      await getIt<AgendarTurnoUseCase>().execute(
        nombreCliente: nombre,
        telefonoCliente: telefono,
        servicioSeleccionado: servicio,
        fechaYMD: _fechaYMD,
        hora: hora,
      );

      if (!mounted) return;
      setState(() {
        _enviando = false;
        _nombreCtrl.clear();
        _telefonoCtrl.clear();
        _horaSeleccionada = null;
      });

      await _mostrarConfirmacion(
        servicio: servicio,
        fecha: fecha,
        hora: hora,
        nombre: nombre,
      );

      if (mounted) {
        _cargarHorarios();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _errorHorarios = null;
      });
      _mostrarMensaje('No se pudo reservar: $e');
      _cargarHorarios();
    }
  }

  Future<void> _mostrarConfirmacion({
    required Servicio servicio,
    required DateTime fecha,
    required String hora,
    required String nombre,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.grisFondo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.negro, size: 30),
        ),
        title: const Text(
          'Turno confirmado',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${servicio.nombre} · $hora hs'),
            const SizedBox(height: 4),
            Text(fechaLarga(fecha), style: AppTextStyles.muted),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ACEPTAR'),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _encabezado(context),
                  const SizedBox(height: 24),
                  const SectionTitle('1. Elegí tu servicio'),
                  if (_servicios.isEmpty)
                    const Text(
                      'No hay servicios disponibles por el momento.',
                      style: AppTextStyles.muted,
                    )
                  else
                    ..._servicios.map(
                      (servicio) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ServiceSelectCard(
                          servicio: servicio,
                          selected: _servicioSeleccionado?.id == servicio.id,
                          onTap: () => _seleccionarServicio(servicio),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SectionTitle('2. Fecha y horario'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grisBorde),
                    ),
                    child: SizedBox(
                      height: 330,
                      child: CalendarDatePicker(
                        initialDate: _fechaSeleccionada,
                        firstDate: _hoy,
                        lastDate: _hoy.add(const Duration(days: 90)),
                        onDateChanged: _seleccionarFecha,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TimeSlotGrid(
                    horarios: _horarios,
                    seleccionado: _horaSeleccionada,
                    onSelected: (hora) {
                      setState(() => _horaSeleccionada = hora);
                    },
                    cargando: _cargandoHorarios,
                    error: _errorHorarios,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Los horarios se calculan según la configuración del local.',
                    style: AppTextStyles.muted,
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('3. Completá tus datos'),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nombreCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresá tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefonoCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono de contacto',
                          ),
                          validator: (value) {
                            final telefono = value?.trim() ?? '';
                            if (telefono.isEmpty) {
                              return 'Ingresá tu teléfono';
                            }
                            if (!RegExp(r'^[0-9]{6,}$').hasMatch(telefono)) {
                              return 'Ingresá un teléfono numérico';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _enviando ? null : _confirmarReserva,
                    child: _enviando
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
                  const SizedBox(height: 20),
                  const Text(
                    'lanotabarbershop.com',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            children: [
              Text(
                'LA NOTA BARBER SHOP',
                textAlign: TextAlign.center,
                style: AppTextStyles.brand.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Reservá tu turno',
                style: AppTextStyles.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Panel administrador',
          icon: const Icon(Icons.admin_panel_settings_outlined),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.admin);
          },
        ),
      ],
    );
  }
}
