import 'package:flutter/material.dart';

import '../../domain/entities/turno.dart';
import '../theme/app_theme.dart';

class TurnoCard extends StatelessWidget {
  final Turno turno;
  final VoidCallback onCancel;

  const TurnoCard({super.key, required this.turno, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.negro,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                turno.hora,
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(turno.cliente.nombre, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(turno.servicio.nombre, style: AppTextStyles.muted),
                  const SizedBox(height: 4),
                  Text(
                    'Tel: ${turno.cliente.telefono}  |  \$${turno.servicio.precio.toStringAsFixed(0)}',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCancel,
              tooltip: 'Cancelar turno',
              icon: const Icon(Icons.close, color: AppColors.grisTexto),
            ),
          ],
        ),
      ),
    );
  }
}
