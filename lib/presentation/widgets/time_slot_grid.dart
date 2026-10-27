import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<String> horarios;
  final String? seleccionado;
  final ValueChanged<String> onSelected;
  final bool cargando;
  final String? error;

  const TimeSlotGrid({
    super.key,
    required this.horarios,
    required this.seleccionado,
    required this.onSelected,
    this.cargando = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (error != null) {
      return Text(error!, style: const TextStyle(color: AppColors.rojo));
    }

    if (horarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No hay horarios disponibles para este día.',
          style: AppTextStyles.muted,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: horarios.map((hora) {
        final activo = hora == seleccionado;
        return InkWell(
          onTap: () => onSelected(hora),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 82,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: activo ? AppColors.negro : AppColors.blanco,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activo ? AppColors.negro : AppColors.grisBorde,
              ),
            ),
            child: Text(
              hora,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: activo ? AppColors.blanco : AppColors.negro,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
