import 'package:barber_shop/application/use_cases/actualizar_precio_servicio.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('ActualizarPrecioServicioUseCase', () {
    late FakeServicioRepository repository;
    late ActualizarPrecioServicioUseCase useCase;

    setUp(() {
      repository = FakeServicioRepository(
        servicios: [
          Servicio(
            id: '1',
            nombre: 'Corte Tradicional',
            duracionMinutos: 30,
            precio: 5000,
          ),
        ],
      );
      useCase = ActualizarPrecioServicioUseCase(repository);
    });

    test('actualiza el precio de un servicio existente', () async {
      await useCase.execute('1', 6500);

      expect(repository.findById('1')!.precio, 6500);
    });

    test('rechaza precios menores o iguales a cero', () async {
      await expectLater(useCase.execute('1', 0), throwsA(isA<Exception>()));
      expect(repository.findById('1')!.precio, 5000);
    });

    test('informa cuando el servicio no existe', () async {
      await expectLater(
        useCase.execute('999', 6500),
        throwsA(isA<ServicioNotFoundException>()),
      );
    });

    test('propaga errores de persistencia', () async {
      repository.failOnUpdate = true;

      await expectLater(
        useCase.execute('1', 6500),
        throwsA(isA<PersistenceFailureException>()),
      );
      expect(repository.findById('1')!.precio, 5000);
    });
  });
}
