class DemoConfig {
  static const bool enabled = bool.fromEnvironment('DEMO_MODE');
  static const bool forceError = bool.fromEnvironment('DEMO_ERROR');

  static int _intentosError = 0;

  static Future<void> pausa() async {
    if (enabled || forceError) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  static void maybeThrowOnce() {
    if (forceError && _intentosError == 0) {
      _intentosError++;
      throw Exception('Error simulado para la demostración.');
    }
  }
}
