import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/domain/ports/configuracion_repository.dart';
import 'package:barber_shop/domain/ports/servicio_repository.dart';
import 'package:barber_shop/domain/ports/turno_repository.dart';

class FakeTurnoRepository implements TurnoRepository {
  FakeTurnoRepository({List<Turno>? turnos}) : turnos = turnos ?? [];

  final List<Turno> turnos;
  bool failOnSave = false;
  bool failOnDelete = false;

  @override
  Future<void> save(Turno turno) async {
    if (failOnSave) {
      throw PersistenceFailureException('Fallo simulado al guardar');
    }

    final index = turnos.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      turnos[index] = turno;
    } else {
      turnos.add(turno);
    }
  }

  @override
  bool existsAtTime(String fechaYMD, String hora) {
    return turnos.any((t) => t.fechaYMD == fechaYMD && t.hora == hora);
  }

  @override
  List<Turno> findByDate(String fechaYMD) {
    return turnos.where((t) => t.fechaYMD == fechaYMD).toList();
  }

  @override
  Future<void> delete(String id) async {
    if (failOnDelete) {
      throw PersistenceFailureException('Fallo simulado al eliminar');
    }

    final index = turnos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }
    turnos.removeAt(index);
  }

  @override
  List<Turno> findByClienteTelefono(String telefono) {
    return turnos.where((t) => t.cliente.telefono == telefono).toList();
  }
}

class FakeServicioRepository implements ServicioRepository {
  FakeServicioRepository({List<Servicio>? servicios})
    : servicios = servicios ?? [];

  final List<Servicio> servicios;
  bool failOnSave = false;
  bool failOnUpdate = false;

  @override
  List<Servicio> findAll() {
    return List.unmodifiable(servicios);
  }

  @override
  Servicio? findById(String id) {
    for (final servicio in servicios) {
      if (servicio.id == id) {
        return servicio;
      }
    }
    return null;
  }

  @override
  Future<void> save(Servicio servicio) async {
    if (failOnSave) {
      throw PersistenceFailureException('Fallo simulado al guardar');
    }

    final index = servicios.indexWhere((s) => s.id == servicio.id);
    if (index >= 0) {
      servicios[index] = servicio;
    } else {
      servicios.add(servicio);
    }
  }

  @override
  Future<void> updatePrecio(String id, double nuevoPrecio) async {
    if (failOnUpdate) {
      throw PersistenceFailureException('Fallo simulado al actualizar');
    }

    final index = servicios.indexWhere((s) => s.id == id);
    if (index < 0) {
      throw ServicioNotFoundException(id);
    }

    final actual = servicios[index];
    servicios[index] = Servicio(
      id: actual.id,
      nombre: actual.nombre,
      duracionMinutos: actual.duracionMinutos,
      precio: nuevoPrecio,
    );
  }
}

class FakeConfiguracionRepository implements ConfiguracionRepository {
  ConfiguracionAgenda configuracion = ConfiguracionAgenda.defaults();
  bool modoOscuro = false;
  bool failOnSave = false;

  @override
  Future<void> saveHorarioAtencion(ConfiguracionAgenda configuracion) async {
    if (failOnSave) {
      throw ConfiguracionFailureException('Fallo simulado al guardar');
    }
    this.configuracion = configuracion;
  }

  @override
  Future<ConfiguracionAgenda> getHorarioAtencion() async {
    return configuracion;
  }

  @override
  Future<void> saveModoOscuro(bool esModoOscuro) async {
    modoOscuro = esModoOscuro;
  }

  @override
  Future<bool> getModoOscuro() async {
    return modoOscuro;
  }
}
