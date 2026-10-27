import 'package:flutter/material.dart';

import '../../application/use_cases/cancelar_turno.dart';
import '../../application/use_cases/obtener_turnos_por_dia.dart';
import '../../domain/entities/turno.dart';
import '../../injection_container.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/cancelar_turno_dialog.dart';
import '../widgets/date_bubble.dart';
import '../widgets/nuevo_turno_sheet.dart';
import '../widgets/section_title.dart';
import '../widgets/turno_card.dart';

class AgendaMainScreen extends StatefulWidget {
  const AgendaMainScreen({super.key});

  @override
  State<AgendaMainScreen> createState() => _AgendaMainScreenState();
}

class _AgendaMainScreenState extends State<AgendaMainScreen> {
  DateTime _fechaSeleccionada = soloFecha(DateTime.now());
  List<Turno> _turnosDelDia = [];

  @override
  void initState() {
    super.initState();
    _cargarTurnos();
  }

  String get _fechaYMD => fechaYMD(_fechaSeleccionada);

  List<DateTime> get _fechasVisibles {
    final inicio = _fechaSeleccionada.subtract(const Duration(days: 3));
    return List.generate(7, (index) => inicio.add(Duration(days: index)));
  }

  void _cargarTurnos() {
    final useCase = getIt<ObtenerTurnosPorDiaUseCase>();
    setState(() {
      _turnosDelDia = useCase.execute(_fechaYMD);
    });
  }

  void _seleccionarFecha(DateTime fecha) {
    final normalizada = soloFecha(fecha);
    if (normalizada == _fechaSeleccionada) return;
    setState(() => _fechaSeleccionada = normalizada);
    _cargarTurnos();
  }

  Future<void> _abrirCalendario() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      _seleccionarFecha(fecha);
    }
  }

  Future<void> _cancelarTurno(Turno turno) async {
    final confirmado = await mostrarDialogoCancelarTurno(context, turno);
    if (!confirmado) return;

    try {
      await getIt<CancelarTurnoUseCase>().execute(turno.id);
      if (!mounted) return;
      _cargarTurnos();
      _mostrarMensaje('Turno cancelado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo cancelar el turno: $e');
    }
  }

  Future<void> _abrirNuevoTurno() async {
    final creado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.blanco,
      builder: (_) =>
          NuevoTurnoSheet(fecha: _fechaSeleccionada, fechaYMD: _fechaYMD),
    );

    if (creado == true && mounted) {
      _cargarTurnos();
      _mostrarMensaje('Turno agendado correctamente.');
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
      selected: AdminSection.agenda,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(
              'Agenda de turnos',
              trailing: IconButton(
                tooltip: 'Elegir fecha',
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: _abrirCalendario,
              ),
            ),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _fechasVisibles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final fecha = _fechasVisibles[index];
                  return DateBubble(
                    fecha: fecha,
                    selected: fechaYMD(fecha) == _fechaYMD,
                    onTap: () => _seleccionarFecha(fecha),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _turnosDelDia.isEmpty
                  ? const _AgendaVacia()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: _turnosDelDia.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final turno = _turnosDelDia[index];
                        return TurnoCard(
                          turno: turno,
                          onCancel: () => _cancelarTurno(turno),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoTurno,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo turno'),
      ),
    );
  }
}

class _AgendaVacia extends StatelessWidget {
  const _AgendaVacia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 44,
            color: AppColors.grisTexto,
          ),
          SizedBox(height: 12),
          Text('No hay turnos para esta fecha.', style: AppTextStyles.muted),
        ],
      ),
    );
  }
}
