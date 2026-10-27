import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/infrastructure/adapters/shared_preferences_config_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late SharedPreferencesConfigAdapter adapter;

  setUp(() async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    adapter = SharedPreferencesConfigAdapter(preferences);
  });

  group('SharedPreferencesConfigAdapter', () {
    test('devuelve la configuración por defecto', () async {
      final configuracion = await adapter.getHorarioAtencion();

      expect(configuracion.apertura, '09:00');
      expect(configuracion.cierre, '20:00');
      expect(configuracion.duracionBloqueMinutos, 30);
    });

    test('guarda y recupera la configuración', () async {
      await adapter.saveHorarioAtencion(
        const ConfiguracionAgenda(
          apertura: '08:30',
          cierre: '19:00',
          duracionBloqueMinutos: 45,
        ),
      );

      final configuracion = await adapter.getHorarioAtencion();

      expect(configuracion.apertura, '08:30');
      expect(configuracion.cierre, '19:00');
      expect(configuracion.duracionBloqueMinutos, 45);
    });

    test('guarda y recupera la preferencia de modo oscuro', () async {
      expect(await adapter.getModoOscuro(), isFalse);

      await adapter.saveModoOscuro(true);

      expect(await adapter.getModoOscuro(), isTrue);
    });
  });
}
