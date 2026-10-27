import 'package:flutter/material.dart';

class AppColors {
  static const negro = Color(0xFF080F0F);
  static const azulNoche = Color(0xFF011627);
  static const blanco = Color(0xFFFDFFFC);
  static const grisFondo = Color(0xFFF1F3F2);
  static const grisBorde = Color(0xFFD8DDDB);
  static const grisTexto = Color(0xFF687170);
  static const rojo = Color(0xFFB3261E);
}

class AppTextStyles {
  static const brand = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
    color: AppColors.negro,
  );

  static const section = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.negro,
  );

  static const muted = TextStyle(fontSize: 12, color: AppColors.grisTexto);

  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.negro,
  );
}

class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.negro,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.negro,
          onPrimary: AppColors.blanco,
          secondary: AppColors.azulNoche,
          onSecondary: AppColors.blanco,
          surface: AppColors.blanco,
          onSurface: AppColors.negro,
          error: AppColors.rojo,
          onError: AppColors.blanco,
          outline: AppColors.grisBorde,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.blanco,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blanco,
        foregroundColor: AppColors.negro,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.negro,
        ),
      ),
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.negro, displayColor: AppColors.negro)
          .copyWith(
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            bodyMedium: const TextStyle(fontSize: 14, height: 1.4),
            bodySmall: AppTextStyles.muted,
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grisFondo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grisBorde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grisBorde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.negro, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.grisTexto),
        hintStyle: const TextStyle(color: AppColors.grisTexto),
        prefixIconColor: AppColors.grisTexto,
        suffixIconColor: AppColors.grisTexto,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.negro,
          foregroundColor: AppColors.blanco,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.negro,
          side: const BorderSide(color: AppColors.grisBorde),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.negro),
      ),
      cardTheme: CardThemeData(
        color: AppColors.blanco,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.grisBorde),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grisBorde,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.azulNoche,
        contentTextStyle: TextStyle(color: AppColors.blanco),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.blanco,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.negro,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.negro,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.blanco,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.blanco,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.azulNoche,
        headerForegroundColor: AppColors.blanco,
        todayBorder: BorderSide(color: AppColors.negro),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.negro,
        foregroundColor: AppColors.blanco,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.blanco,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
