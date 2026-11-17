import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'injection_container.dart';
import 'presentation/app_routes.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/pages/admin_gate.dart';
import 'presentation/pages/agenda_admin_page.dart';
import 'presentation/pages/bloqueos_admin_page.dart';
import 'presentation/pages/configuracion_agenda_page.dart';
import 'presentation/pages/historial_cliente_page.dart';
import 'presentation/pages/reserva_cliente_page.dart';
import 'presentation/pages/servicios_admin_page.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies(mode: kIsWeb ? StorageMode.remote : StorageMode.local);

  runApp(
    BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthIniciado()),
      child: const BarberiaApp(),
    ),
  );
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
        AppRoutes.admin: (_) => const AdminGate(child: AgendaAdminPage()),
        AppRoutes.adminServicios: (_) =>
            const AdminGate(child: ServiciosAdminPage()),
        AppRoutes.adminConfiguracion: (_) =>
            const AdminGate(child: ConfiguracionAgendaPage()),
        AppRoutes.adminHistorial: (_) =>
            const AdminGate(child: HistorialClientePage()),
        AppRoutes.adminBloqueos: (_) =>
            const AdminGate(child: BloqueosAdminPage()),
      },
    );
  }
}
