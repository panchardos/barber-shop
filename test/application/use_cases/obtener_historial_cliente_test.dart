import 'package:barber_shop/application/use_cases/obtener_historial_cliente.dart';
import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ObtenerHistorialClienteUseCase', () {
    late FakeTurnoRepository repository;
    late ObtenerHistorialClienteUseCase useCase;

    Turno construirTurno({
      required String id,
      required String telefono,
      required String fecha,
      required String hora,
    }) {
      return Turno(
        id: id,
        cliente: Cliente(nombre: 'Cliente $id', telefono: telefono),
        servicio: Servicio(
          id: '1',
          nombre: 'Corte Tradicional',
          duracionMinutos: 30,
          precio: 5000,
        ),
        fechaYMD: fecha,
        hora: hora,
      );
    }

    setUp(() {
      repository = FakeTurnoRepository(
        turnos: [
          construirTurno(
            id: '1',
            telefono: '2611234567',
            fecha: '2026-10-24',
            hora: '10:00',
          ),
          construirTurno(
            id: '2',
            telefono: '2611234567',
            fecha: '2026-10-26',
            hora: '11:00',
          ),
          construirTurno(
            id: '3',
            telefono: '2617654321',
            fecha: '2026-10-25',
            hora: '12:00',
          ),
        ],
      );
      useCase = ObtenerHistorialClienteUseCase(repository);
    });

    test('retorna solamente los turnos del teléfono consultado', () async {
      final historial = useCase.execute('2611234567');

      expect(historial, hasLength(2));
      expect(
        historial.every((t) => t.cliente.telefono == '2611234567'),
        isTrue,
      );
    });

    test('retorna una lista vacía cuando no hay coincidencias', () async {
      final historial = useCase.execute('0000000000');

      expect(historial, isEmpty);
    });

    test('rechaza un teléfono vacío', () async {
      await expectLater(
        Future.sync(() => useCase.execute('   ')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
