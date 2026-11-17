import 'package:barber_shop_server/domain/server_availability.dart';
import 'package:test/test.dart';

void main() {
  group('ServerAvailability', () {
    const config = {
      'apertura': '09:00',
      'cierre': '12:00',
      'duracion_bloque_minutos': 30,
    };
    const service30 = {'duracion_minutos': 30};
    const service45 = {'duracion_minutos': 45};
    final ahora = DateTime(2030, 1, 15, 8);

    test('genera bloques disponibles', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service30,
        occupied: const [],
        now: ahora,
      );

      expect(slots, ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30']);
    });

    test('respeta la duración del servicio', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service45,
        occupied: const [],
        now: ahora,
      );

      expect(slots, ['09:00', '09:30', '10:00', '10:30', '11:00']);
    });

    test('excluye turnos superpuestos', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service30,
        occupied: [
          {'hora': '10:00', 'servicio_duracion': 45},
        ],
        now: ahora,
      );

      expect(slots, isNot(contains('10:00')));
      expect(slots, isNot(contains('10:30')));
      expect(slots, contains('09:30'));
      expect(slots, contains('11:00'));
    });

    test('retorna vacío para fechas pasadas', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2029-01-15',
        config: config,
        service: service30,
        occupied: const [],
        now: ahora,
      );

      expect(slots, isEmpty);
    });

    test('omite horarios pasados del día actual', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service30,
        occupied: const [],
        now: DateTime(2030, 1, 15, 10, 15),
      );

      expect(slots, ['10:30', '11:00', '11:30']);
    });

    test('omite los horarios que caen dentro de la pausa', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: const {
          'apertura': '09:00',
          'cierre': '12:00',
          'duracion_bloque_minutos': 30,
          'pausa_inicio': '10:00',
          'pausa_fin': '11:00',
        },
        service: service30,
        occupied: const [],
        now: ahora,
      );

      expect(slots, ['09:00', '09:30', '11:00', '11:30']);
    });

    test('omite los horarios dentro de un bloqueo por rango', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service30,
        occupied: const [],
        bloqueos: const [
          {
            'todo_el_dia': 0,
            'hora_inicio': '10:00',
            'hora_fin': '11:00',
          },
        ],
        now: ahora,
      );

      expect(slots, ['09:00', '09:30', '11:00', '11:30']);
    });

    test('no ofrece horarios con un bloqueo de todo el día', () {
      final slots = ServerAvailability.availableSlots(
        fechaYMD: '2030-01-15',
        config: config,
        service: service30,
        occupied: const [],
        bloqueos: const [
          {'todo_el_dia': 1},
        ],
        now: ahora,
      );

      expect(slots, isEmpty);
    });

    test('valida configuración', () {
      expect(
        () => ServerAvailability.validateConfig(
          apertura: '12:00',
          cierre: '09:00',
          duracionBloqueMinutos: 30,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ServerAvailability.validateConfig(
          apertura: '09:00',
          cierre: '12:00',
          duracionBloqueMinutos: 30,
          pausaInicio: '08:00',
          pausaFin: '10:00',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
