import 'package:flutter/material.dart';
import 'injection_container.dart';
import 'presentation/screens/agenda_main_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const AgendaMainScreen(),
    );
  }
}
