import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'injection_container.dart';
import 'presentation/app_routes.dart';
import 'presentation/screens/agenda_main_screen.dart';
import 'presentation/screens/configuracion_agenda_screen.dart';
import 'presentation/screens/historial_cliente_screen.dart';
import 'presentation/screens/reserva_cliente_screen.dart';
import 'presentation/screens/servicios_admin_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la Inyección de Dependencias con almacenamiento real
  // (SQLite + SharedPreferences).
  await initDependencies(useRealStorage: true);

  runApp(const BarberiaApp());
}

class BarberiaApp extends StatelessWidget {
  const BarberiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Nota Barber Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.reserva,
      routes: {
        AppRoutes.reserva: (_) => const ReservaClienteScreen(),
        AppRoutes.admin: (_) => const AgendaMainScreen(),
        AppRoutes.adminServicios: (_) => const ServiciosAdminScreen(),
        AppRoutes.adminConfiguracion: (_) => const ConfiguracionAgendaScreen(),
        AppRoutes.adminHistorial: (_) => const HistorialClienteScreen(),
      },
    );
  }
}
