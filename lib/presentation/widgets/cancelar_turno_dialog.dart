import 'package:flutter/material.dart';

import '../../domain/entities/turno.dart';
import '../theme/app_theme.dart';

Future<bool> mostrarDialogoCancelarTurno(
  BuildContext context,
  Turno turno,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.negro,
        size: 34,
      ),
      title: const Text(
        '¿Cancelar este turno?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Se dará de baja la reserva de las ${turno.hora} hs de ${turno.cliente.nombre}. '
        'El espacio se liberará para nuevos turnos.',
        textAlign: TextAlign.center,
        style: const TextStyle(height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('SÍ, CANCELAR TURNO'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('VOLVER ATRÁS'),
          ),
        ),
      ],
    ),
  );

  return resultado ?? false;
}
