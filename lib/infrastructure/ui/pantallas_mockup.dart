import 'package:flutter/material.dart';

// 1. Pantalla de Reserva (Cliente)
class PantallaReserva extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservar Turno')),
      body: Center(child: Text('Formulario y Catálogo de Servicios (Llama a AgendarTurnoUseCase)')),
    );
  }
}

// 2. Pantalla de Agenda (Admin)
class PantallaAgendaAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agenda Diaria')),
      body: Center(child: Text('Lista de Turnos (Llama a ObtenerTurnosPorDiaUseCase)')),
    );
  }
}

// 3. Modal de Cancelación (Admin)
class ModalCancelacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('¿Cancelar Turno?'),
      content: Text('Acción irreversible.'),
      actions: [
        TextButton(onPressed: () {}, child: Text('Confirmar (Llama a CancelarTurnoUseCase)'))
      ],
    );
  }
}

// 4. Pantalla de Catálogo y Precios (Admin)
class PantallaCatalogoAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Precios')),
      body: Center(child: Text('Editor de Precios (Llama a ActualizarPrecioServicioUseCase)')),
    );
  }
}