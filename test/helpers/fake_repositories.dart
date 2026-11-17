import 'package:barber_shop/domain/entities/bloqueo.dart';
import 'package:barber_shop/domain/entities/configuracion_agenda.dart';
import 'package:barber_shop/domain/entities/estado_turno.dart';
import 'package:barber_shop/domain/entities/servicio.dart';
import 'package:barber_shop/domain/entities/turno.dart';
import 'package:barber_shop/domain/exceptions/domain_exceptions.dart';
import 'package:barber_shop/domain/ports/auth_repository.dart';
import 'package:barber_shop/domain/ports/bloqueo_repository.dart';
import 'package:barber_shop/domain/ports/configuracion_repository.dart';
import 'package:barber_shop/domain/ports/servicio_repository.dart';
import 'package:barber_shop/domain/ports/turno_repository.dart';

class FakeTurnoRepository implements TurnoRepository {
  FakeTurnoRepository({List<Turno>? turnos}) : turnos = turnos ?? [];

  final List<Turno> turnos;
  bool failOnSave = false;
  bool failOnCancelar = false;

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
  Future<bool> existsAtTime(String fechaYMD, String hora) async {
    return turnos.any(
      (t) =>
          t.fechaYMD == fechaYMD &&
          t.hora == hora &&
          t.estado == EstadoTurno.reservado,
    );
  }

  @override
  Future<List<Turno>> findByDate(String fechaYMD) async {
    return turnos
        .where(
          (t) =>
              t.fechaYMD == fechaYMD && t.estado == EstadoTurno.reservado,
        )
        .toList();
  }

  @override
  Future<void> cancelar(String id) async {
    if (failOnCancelar) {
      throw PersistenceFailureException('Fallo simulado al cancelar');
    }

    final index = turnos.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TurnoNotFoundException(id);
    }
    turnos[index] = turnos[index].copyWith(estado: EstadoTurno.cancelado);
  }

  @override
  Future<List<Turno>> findByClienteTelefono(String telefono) async {
    return turnos.where((t) => t.cliente.telefono == telefono).toList();
  }
}

class FakeBloqueoRepository implements BloqueoRepository {
  FakeBloqueoRepository({List<Bloqueo>? bloqueos})
    : bloqueos = bloqueos ?? [];

  final List<Bloqueo> bloqueos;
  bool failOnSave = false;
  bool failOnDelete = false;

  @override
  Future<void> save(Bloqueo bloqueo) async {
    if (failOnSave) {
      throw PersistenceFailureException('Fallo simulado al guardar');
    }
    final index = bloqueos.indexWhere((b) => b.id == bloqueo.id);
    if (index >= 0) {
      bloqueos[index] = bloqueo;
    } else {
      bloqueos.add(bloqueo);
    }
  }

  @override
  Future<void> delete(String id) async {
    if (failOnDelete) {
      throw PersistenceFailureException('Fallo simulado al eliminar');
    }
    final index = bloqueos.indexWhere((b) => b.id == id);
    if (index < 0) {
      throw BloqueoNotFoundException(id);
    }
    bloqueos.removeAt(index);
  }

  @override
  Future<List<Bloqueo>> findByDate(String fechaYMD) async {
    return bloqueos
        .where((bloqueo) => bloqueo.fechaYMD == fechaYMD)
        .toList();
  }
}

class FakeServicioRepository implements ServicioRepository {
  FakeServicioRepository({List<Servicio>? servicios})
    : servicios = servicios ?? [];

  final List<Servicio> servicios;
  bool failOnSave = false;
  bool failOnUpdate = false;

  @override
  Future<List<Servicio>> findAll() async {
    return List.unmodifiable(servicios);
  }

  @override
  Future<Servicio?> findById(String id) async {
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

class FakeAuthRepository implements AuthRepository {
  bool autenticado = false;
  bool failOnLogin = false;
  String? _token;

  @override
  Future<void> login({
    required String usuario,
    required String password,
  }) async {
    if (failOnLogin) {
      throw AuthenticationFailureException('Credenciales inválidas.');
    }
    autenticado = true;
    _token = 'token-demo';
  }

  @override
  Future<void> logout() async {
    autenticado = false;
    _token = null;
  }

  @override
  bool get estaAutenticado => autenticado;

  @override
  String? get token => _token;
}
