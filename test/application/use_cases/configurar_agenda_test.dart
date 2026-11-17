import 'package:barber_shop/application/use_cases/configurar_agenda.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ConfigurarAgendaUseCase', () {
    late FakeConfiguracionRepository repository;
    late ConfigurarAgendaUseCase useCase;

    setUp(() {
      repository = FakeConfiguracionRepository();
      useCase = ConfigurarAgendaUseCase(repository);
    });

    test('guarda y recupera la configuración de la agenda', () async {
      await useCase.guardarHorario(
        apertura: '08:30',
        cierre: '19:00',
        duracionBloque: 45,
      );

      final configuracion = await useCase.obtenerHorario();

      expect(configuracion.apertura, '08:30');
      expect(configuracion.cierre, '19:00');
      expect(configuracion.duracionBloqueMinutos, 45);
      expect(configuracion.pausaInicio, isNull);
      expect(configuracion.pausaFin, isNull);
    });

    test('guarda y recupera una pausa válida', () async {
      await useCase.guardarHorario(
        apertura: '09:00',
        cierre: '20:00',
        duracionBloque: 30,
        pausaInicio: '13:00',
        pausaFin: '14:00',
      );

      final configuracion = await useCase.obtenerHorario();

      expect(configuracion.pausaInicio, '13:00');
      expect(configuracion.pausaFin, '14:00');
    });

    test('rechaza una pausa incompleta o fuera del horario', () async {
      await expectLater(
        useCase.guardarHorario(
          apertura: '09:00',
          cierre: '20:00',
          duracionBloque: 30,
          pausaInicio: '13:00',
        ),
        throwsA(isA<ConfiguracionInvalidaException>()),
      );

      await expectLater(
        useCase.guardarHorario(
          apertura: '09:00',
          cierre: '20:00',
          duracionBloque: 30,
          pausaInicio: '08:00',
          pausaFin: '10:00',
        ),
        throwsA(isA<ConfiguracionInvalidaException>()),
      );
    });

    test('devuelve los valores por defecto si no se guardó nada', () async {
      final configuracion = await useCase.obtenerHorario();

      expect(configuracion.apertura, '09:00');
      expect(configuracion.cierre, '20:00');
      expect(configuracion.duracionBloqueMinutos, 30);
    });

    test('propaga errores de persistencia', () async {
      repository.failOnSave = true;

      await expectLater(
        useCase.guardarHorario(
          apertura: '08:30',
          cierre: '19:00',
          duracionBloque: 45,
        ),
        throwsA(isA<ConfiguracionFailureException>()),
      );
    });
  });
}
