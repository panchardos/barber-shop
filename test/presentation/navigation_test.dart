import 'package:barber_shop/injection_container.dart';
import 'package:barber_shop/presentation/app_routes.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_event.dart';
import 'package:barber_shop/presentation/pages/admin_gate.dart';
import 'package:barber_shop/presentation/pages/agenda_admin_page.dart';
import 'package:barber_shop/presentation/pages/configuracion_agenda_page.dart';
import 'package:barber_shop/presentation/pages/historial_cliente_page.dart';
import 'package:barber_shop/presentation/pages/reserva_cliente_page.dart';
import 'package:barber_shop/presentation/pages/servicios_admin_page.dart';
import 'package:barber_shop/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await initDependencies(mode: StorageMode.memory);
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  Widget app() {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthIniciado()),
      child: MaterialApp(
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
        },
      ),
    );
  }

  testWidgets('el cliente puede entrar al panel administrador', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Panel administrador'));
    await tester.pumpAndSettle();

    expect(find.text('Panel Control'), findsOneWidget);
    expect(find.text('AGENDA DE TURNOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el menú del admin navega a servicios', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Panel administrador'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Servicios'));
    await tester.pumpAndSettle();

    expect(find.text('SERVICIOS OFRECIDOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el administrador puede volver al sitio del cliente', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Panel administrador'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al sitio'));
    await tester.pumpAndSettle();

    expect(find.text('LA NOTA BARBER SHOP'), findsOneWidget);
    expect(find.text('Panel Control'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
