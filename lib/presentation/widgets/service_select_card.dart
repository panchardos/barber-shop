import 'package:flutter/material.dart';

import '../../domain/entities/servicio.dart';
import '../theme/app_theme.dart';

class ServiceSelectCard extends StatelessWidget {
  final Servicio servicio;
  final bool selected;
  final VoidCallback onTap;

  const ServiceSelectCard({
    super.key,
    required this.servicio,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.negro : AppColors.grisBorde,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(servicio.nombre, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      '${servicio.duracionMinutos} min  |  \$${servicio.precio.toStringAsFixed(0)}',
                      style: AppTextStyles.muted,
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.negro : AppColors.grisTexto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
