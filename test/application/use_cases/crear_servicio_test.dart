import 'package:barber_shop/application/use_cases/crear_servicio.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('CrearServicioUseCase', () {
    late FakeServicioRepository repository;
    late CrearServicioUseCase useCase;

    setUp(() {
      repository = FakeServicioRepository();
      useCase = CrearServicioUseCase(repository);
    });

    test('crea un servicio válido', () async {
      final id = await useCase.execute(
        nombre: 'Coloración',
        duracionMinutos: 60,
        precio: 12000,
      );

      expect(id, isNotEmpty);
      expect(repository.servicios, hasLength(1));
      expect(repository.servicios.single.nombre, 'Coloración');
      expect(repository.servicios.single.duracionMinutos, 60);
      expect(repository.servicios.single.precio, 12000);
    });

    test('rechaza un nombre vacío', () async {
      await expectLater(
        useCase.execute(nombre: '   ', duracionMinutos: 60, precio: 12000),
        throwsA(isA<ServicioInvalidoException>()),
      );
    });

    test('rechaza una duración inválida', () async {
      await expectLater(
        useCase.execute(
          nombre: 'Coloración',
          duracionMinutos: 0,
          precio: 12000,
        ),
        throwsA(isA<ServicioInvalidoException>()),
      );
    });

    test('rechaza un precio inválido', () async {
      await expectLater(
        useCase.execute(nombre: 'Coloración', duracionMinutos: 60, precio: 0),
        throwsA(isA<ServicioInvalidoException>()),
      );
    });

    test('propaga errores de persistencia', () async {
      repository.failOnSave = true;

      await expectLater(
        useCase.execute(
          nombre: 'Coloración',
          duracionMinutos: 60,
          precio: 12000,
        ),
        throwsA(isA<PersistenceFailureException>()),
      );
    });
  });
}
