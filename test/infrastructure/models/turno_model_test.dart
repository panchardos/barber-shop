import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/infrastructure/models/turno_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TurnoModel', () {
    final turno = Turno(
      id: 'TRN-1',
      cliente: Cliente(nombre: 'Ana Pérez', telefono: '2611234567'),
      servicio: Servicio(
        id: '1',
        nombre: 'Corte Tradicional',
        duracionMinutos: 30,
        precio: 5000,
      ),
      fechaYMD: '2026-10-26',
      hora: '10:30',
    );

    test('convierte una entidad a modelo y de vuelta a entidad', () {
      final model = TurnoModel.fromEntity(turno);
      final entity = model.toEntity();

      expect(entity.id, turno.id);
      expect(entity.cliente.nombre, turno.cliente.nombre);
      expect(entity.cliente.telefono, turno.cliente.telefono);
      expect(entity.servicio.id, turno.servicio.id);
      expect(entity.servicio.nombre, turno.servicio.nombre);
      expect(entity.servicio.duracionMinutos, turno.servicio.duracionMinutos);
      expect(entity.servicio.precio, turno.servicio.precio);
      expect(entity.fechaYMD, turno.fechaYMD);
      expect(entity.hora, turno.hora);
    });

    test('convierte a mapa SQLite y de vuelta al modelo', () {
      final model = TurnoModel.fromEntity(turno);
      final map = model.toSqflite();
      final desdeMapa = TurnoModel.fromSqflite(map);

      expect(desdeMapa.id, turno.id);
      expect(desdeMapa.clienteNombre, turno.cliente.nombre);
      expect(desdeMapa.clienteTelefono, turno.cliente.telefono);
      expect(desdeMapa.servicioId, turno.servicio.id);
      expect(desdeMapa.servicioNombre, turno.servicio.nombre);
      expect(desdeMapa.servicioDuracion, turno.servicio.duracionMinutos);
      expect(desdeMapa.servicioPrecio, turno.servicio.precio);
      expect(desdeMapa.fechaYMD, turno.fechaYMD);
      expect(desdeMapa.hora, turno.hora);
    });

    test('los alias fromMap y toMap son equivalentes a SQLite', () {
      final model = TurnoModel.fromEntity(turno);
      final desdeAlias = TurnoModel.fromMap(model.toMap());

      expect(desdeAlias.toEntity().id, turno.id);
      expect(desdeAlias.toEntity().fechaYMD, turno.fechaYMD);
    });
  });
}
