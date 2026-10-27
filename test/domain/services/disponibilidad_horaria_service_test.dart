import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/domain/services/disponibilidad_horaria_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisponibilidadHorariaService', () {
    const service = DisponibilidadHorariaService();
    const fecha = '2030-01-15';
    final ahora = DateTime(2030, 1, 15, 8);

    final configuracion = const ConfiguracionAgenda(
      apertura: '09:00',
      cierre: '12:00',
      duracionBloqueMinutos: 30,
    );

    final servicio30 = Servicio(
      id: '1',
      nombre: 'Corte',
      duracionMinutos: 30,
      precio: 5000,
    );

    final servicio45 = Servicio(
      id: '2',
      nombre: 'Corte + Barba',
      duracionMinutos: 45,
      precio: 7500,
    );

    Turno turno({required String hora, required int duracion}) {
      return Turno(
        id: 'TRN-$hora',
        cliente: Cliente(nombre: 'Cliente', telefono: '2611234567'),
        servicio: Servicio(
          id: 'x',
          nombre: 'Servicio',
          duracionMinutos: duracion,
          precio: 1000,
        ),
        fechaYMD: fecha,
        hora: hora,
      );
    }

    test('genera todos los bloques disponibles', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: fecha,
        configuracion: configuracion,
        servicio: servicio30,
        turnosDelDia: const [],
        ahora: ahora,
      );

      expect(horarios, ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30']);
    });

    test('no ofrece bloques donde el servicio no entra antes del cierre', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: fecha,
        configuracion: configuracion,
        servicio: servicio45,
        turnosDelDia: const [],
        ahora: ahora,
      );

      expect(horarios, ['09:00', '09:30', '10:00', '10:30', '11:00']);
    });

    test('omite el bloque de un turno ocupado', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: fecha,
        configuracion: configuracion,
        servicio: servicio30,
        turnosDelDia: [turno(hora: '10:00', duracion: 30)],
        ahora: ahora,
      );

      expect(horarios, isNot(contains('10:00')));
      expect(horarios, contains('09:30'));
      expect(horarios, contains('10:30'));
    });

    test('omite bloques superpuestos por duración', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: fecha,
        configuracion: configuracion,
        servicio: servicio30,
        turnosDelDia: [turno(hora: '10:00', duracion: 45)],
        ahora: ahora,
      );

      expect(horarios, isNot(contains('10:00')));
      expect(horarios, isNot(contains('10:30')));
      expect(horarios, contains('09:30'));
      expect(horarios, contains('11:00'));
    });

    test('retorna vacío para fechas pasadas', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: '2029-01-15',
        configuracion: configuracion,
        servicio: servicio30,
        turnosDelDia: const [],
        ahora: ahora,
      );

      expect(horarios, isEmpty);
    });

    test('omite horarios pasados si la fecha es hoy', () {
      final horarios = service.calcularHorariosDisponibles(
        fechaYMD: fecha,
        configuracion: configuracion,
        servicio: servicio30,
        turnosDelDia: const [],
        ahora: DateTime(2030, 1, 15, 10, 15),
      );

      expect(horarios, ['10:30', '11:00', '11:30']);
    });

    test('rechaza una configuración inválida', () {
      expect(
        () => service.calcularHorariosDisponibles(
          fechaYMD: fecha,
          configuracion: const ConfiguracionAgenda(
            apertura: '12:00',
            cierre: '09:00',
            duracionBloqueMinutos: 30,
          ),
          servicio: servicio30,
          turnosDelDia: const [],
          ahora: ahora,
        ),
        throwsA(isA<ConfiguracionInvalidaException>()),
      );
    });

    test('estaDisponible verifica un horario puntual', () {
      expect(
        service.estaDisponible(
          fechaYMD: fecha,
          hora: '10:30',
          configuracion: configuracion,
          servicio: servicio30,
          turnosDelDia: const [],
          ahora: ahora,
        ),
        isTrue,
      );
      expect(
        service.estaDisponible(
          fechaYMD: fecha,
          hora: '08:30',
          configuracion: configuracion,
          servicio: servicio30,
          turnosDelDia: const [],
          ahora: ahora,
        ),
        isFalse,
      );
    });
  });
}
