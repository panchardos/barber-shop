abstract class DomainException implements Exception {
  final String message;
  DomainException(this.message);

  @override
  String toString() => message;
}

class PersistenceFailureException extends DomainException {
  PersistenceFailureException(String message) 
      : super("Error técnico en el almacenamiento de datos: $message");
}

class TurnoNotFoundException extends DomainException {
  TurnoNotFoundException(String id) 
      : super("No se encontró el turno con el identificador: $id");
}

class ConfiguracionFailureException extends DomainException {
  ConfiguracionFailureException(String message) 
      : super("Error al acceder a las preferencias locales: $message");
}