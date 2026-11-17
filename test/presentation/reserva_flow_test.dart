import 'package:barber_shop/domain/ports/servicio_repository.dart';
import 'package:barber_shop/injection_container.dart';
import 'package:barber_shop/presentation/app_routes.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_bloc.dart';
import 'package:barber_shop/presentation/blocs/auth/auth_event.dart';
import 'package:barber_shop/presentation/pages/admin_gate.dart';
import 'package:barber_shop/presentation/pages/agenda_admin_page.dart';
import 'package:barber_shop/presentation/pages/reserva_cliente_page.dart';
import 'package:barber_shop/presentation/theme/app_theme.dart';
import 'package:barber_shop/presentation/widgets/nuevo_turno_sheet.dart';
import 'package:barber_shop/presentation/widgets/time_slot_grid.dart';
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

  Widget app({required Widget home, Map<String, WidgetBuilder>? routes}) {
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
        home: home,
        routes: routes ?? const {},
      ),
    );
  }

  testWidgets('muestra el popup de turno confirmado', (tester) async {
    await tester.pumpWidget(app(home: const ReservaClientePage()));
    await tester.pumpAndSettle();

    final slot = find
        .descendant(
          of: find.byType(TimeSlotGrid),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.ensureVisible(slot);
    await tester.pumpAndSettle();
    await tester.tap(slot);
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ana Pérez');
    await tester.enterText(campos.at(1), '2611234567');

    await tester.ensureVisible(find.text('CONFIRMAR RESERVA'));
    await tester.tap(find.text('CONFIRMAR RESERVA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Turno confirmado'), findsOneWidget);
    expect(find.text('Ana Pérez'), findsWidgets);
    expect(find.textContaining('Corte Tradicional'), findsWidgets);
    expect(find.textContaining('hs'), findsWidgets);

    await tester.tap(find.text('ACEPTAR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Turno confirmado'), findsNothing);
  });

  testWidgets('refresca el catálogo al volver del admin', (tester) async {
    await tester.pumpWidget(
      app(
        home: const ReservaClientePage(),
        routes: {
          AppRoutes.admin: (_) =>
              const AdminGate(child: AgendaAdminPage()),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('\$5000'), findsWidgets);

    await tester.tap(find.byTooltip('Panel administrador'));
    await tester.pumpAndSettle();

    await getIt<ServicioRepository>().updatePrecio('1', 6500);

    await tester.tap(find.byTooltip('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al sitio'));
    await tester.pumpAndSettle();

    expect(find.textContaining('\$6500'), findsWidgets);
    expect(find.textContaining('\$5000'), findsNothing);
  });

  testWidgets('muestra el error del nuevo turno dentro del sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        home: Scaffold(
          body: NuevoTurnoSheet(fecha: DateTime(2030, 1, 15)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ana Pérez');
    await tester.enterText(campos.at(1), '2611234567');

    await tester.ensureVisible(find.text('CONFIRMAR RESERVA'));
    await tester.tap(find.text('CONFIRMAR RESERVA'));
    await tester.pumpAndSettle();

    final error = find.byKey(const Key('nuevo-turno-error'));
    expect(error, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NuevoTurnoSheet),
        matching: error,
      ),
      findsOneWidget,
    );
    expect(find.text('Seleccioná un servicio y un horario.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });
}
