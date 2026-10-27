const _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _diasLargos = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String fechaYMD(DateTime fecha) {
  final anio = fecha.year.toString().padLeft(4, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '$anio-$mes-$dia';
}

String diaCorto(DateTime fecha) => _diasCortos[fecha.weekday - 1];

String diaMes(DateTime fecha) => fecha.day.toString().padLeft(2, '0');

String fechaLarga(DateTime fecha) {
  final dia = _diasLargos[fecha.weekday - 1];
  final mes = _meses[fecha.month - 1];
  return '$dia ${fecha.day} de $mes de ${fecha.year}';
}

DateTime soloFecha(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}
