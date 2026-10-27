import 'package:barber_shop/injection_container.dart';
import 'package:barber_shop/presentation/app_routes.dart';
import 'package:barber_shop/presentation/screens/agenda_main_screen.dart';
import 'package:barber_shop/presentation/screens/configuracion_agenda_screen.dart';
import 'package:barber_shop/presentation/screens/historial_cliente_screen.dart';
import 'package:barber_shop/presentation/screens/reserva_cliente_screen.dart';
import 'package:barber_shop/presentation/screens/servicios_admin_screen.dart';
import 'package:barber_shop/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await initDependencies(useRealStorage: false);
  });

  tearDownAll(() async {
    await getIt.reset();
  });

  Widget app() {
    return MaterialApp(
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
