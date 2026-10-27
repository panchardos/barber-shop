import 'package:barber_shop/domain/entities/cliente.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';

Servicio crearServicio({
  String id = '1',
  String nombre = 'Corte Tradicional',
  int duracionMinutos = 30,
  double precio = 5000,
}) {
  return Servicio(
    id: id,
    nombre: nombre,
    duracionMinutos: duracionMinutos,
    precio: precio,
  );
}

Turno crearTurno({
  String id = 'TRN-1',
  String nombreCliente = 'Ana Pérez',
  String telefono = '2611234567',
  String fechaYMD = '2030-01-15',
  String hora = '10:00',
  int duracionServicio = 30,
}) {
  return Turno(
    id: id,
    cliente: Cliente(nombre: nombreCliente, telefono: telefono),
    servicio: Servicio(
      id: '1',
      nombre: 'Corte Tradicional',
      duracionMinutos: duracionServicio,
      precio: 5000,
    ),
    fechaYMD: fechaYMD,
    hora: hora,
  );
}
