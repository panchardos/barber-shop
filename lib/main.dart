import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'injection_container.dart';
import 'presentation/app_routes.dart';
import 'presentation/pages/agenda_admin_page.dart';
import 'presentation/pages/configuracion_agenda_page.dart';
import 'presentation/pages/historial_cliente_page.dart';
import 'presentation/pages/reserva_cliente_page.dart';
import 'presentation/pages/servicios_admin_page.dart';
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
        AppRoutes.reserva: (_) => const ReservaClientePage(),
        AppRoutes.admin: (_) => const AgendaAdminPage(),
        AppRoutes.adminServicios: (_) => const ServiciosAdminPage(),
        AppRoutes.adminConfiguracion: (_) => const ConfiguracionAgendaPage(),
        AppRoutes.adminHistorial: (_) => const HistorialClientePage(),
      },
    );
  }
}
