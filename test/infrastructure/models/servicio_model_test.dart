import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/infrastructure/models/servicio_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServicioModel', () {
    final servicio = Servicio(
      id: '2',
      nombre: 'Arreglo de Barba',
      duracionMinutos: 30,
      precio: 3000,
    );

    test('convierte una entidad a modelo y de vuelta a entidad', () {
      final model = ServicioModel.fromEntity(servicio);
      final entity = model.toEntity();

      expect(entity.id, servicio.id);
      expect(entity.nombre, servicio.nombre);
      expect(entity.duracionMinutos, servicio.duracionMinutos);
      expect(entity.precio, servicio.precio);
    });

    test('convierte a mapa SQLite y de vuelta al modelo', () {
      final model = ServicioModel.fromEntity(servicio);
      final map = model.toSqflite();
      final desdeMapa = ServicioModel.fromSqflite(map);

      expect(desdeMapa.id, servicio.id);
      expect(desdeMapa.nombre, servicio.nombre);
      expect(desdeMapa.duracionMinutos, servicio.duracionMinutos);
      expect(desdeMapa.precio, servicio.precio);
    });

    test('acepta un precio entero y lo normaliza a double', () {
      final model = ServicioModel.fromMap({
        'id': '3',
        'nombre': 'Corte + Barba',
        'duracion_minutos': 45,
        'precio': 7500,
      });

      expect(model.precio, 7500.0);
      expect(model.precio, isA<double>());
    });

    test('los alias fromMap y toMap son equivalentes a SQLite', () {
      final model = ServicioModel.fromEntity(servicio);
      final desdeAlias = ServicioModel.fromMap(model.toMap());

      expect(desdeAlias.toEntity().id, servicio.id);
      expect(desdeAlias.toEntity().precio, servicio.precio);
    });
  });
}
