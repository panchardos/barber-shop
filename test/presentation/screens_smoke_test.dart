import 'package:barber_shop/injection_container.dart';
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

  Widget app(Widget home) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  testWidgets('la pantalla de reserva del cliente se construye', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ReservaClienteScreen()));
    await tester.pumpAndSettle();

    expect(find.text('LA NOTA BARBER SHOP'), findsOneWidget);
    expect(find.text('1. ELEGÍ TU SERVICIO'), findsOneWidget);
    expect(find.text('2. FECHA Y HORARIO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la agenda del administrador se construye', (tester) async {
    await tester.pumpWidget(app(const AgendaMainScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Panel Control'), findsOneWidget);
    expect(find.text('AGENDA DE TURNOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el administrador puede abrir el formulario de nuevo turno', (
    tester,
  ) async {
    await tester.pumpWidget(app(const AgendaMainScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuevo turno'));
    await tester.pumpAndSettle();

    expect(find.text('Agendar nuevo turno'), findsOneWidget);
    expect(find.text('HORARIO DISPONIBLE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la pantalla de servicios del administrador se construye', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ServiciosAdminScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Panel Control'), findsOneWidget);
    expect(find.text('SERVICIOS OFRECIDOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la configuración de agenda se construye', (tester) async {
    await tester.pumpWidget(app(const ConfiguracionAgendaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('PARÁMETROS DEL LOCAL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el historial de cliente se construye', (tester) async {
    await tester.pumpWidget(app(const HistorialClienteScreen()));
    await tester.pumpAndSettle();

    expect(find.text('HISTORIAL DE CLIENTE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
