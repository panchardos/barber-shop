import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/date_formatters.dart';

class DateBubble extends StatelessWidget {
  final DateTime fecha;
  final bool selected;
  final VoidCallback onTap;

  const DateBubble({
    super.key,
    required this.fecha,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.negro : AppColors.blanco,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.negro : AppColors.grisBorde,
          ),
        ),
        child: Column(
          children: [
            Text(
              diaCorto(fecha),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.blanco : AppColors.grisTexto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              diaMes(fecha),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.blanco : AppColors.negro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
